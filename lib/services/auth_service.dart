import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class IAuthService {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  );
  Future<void> signOut();
  Future<User?> signInWithGoogle();
  Stream<User?> get userChanges;
  User? get currentUser;
  String? get errorMessage;
}

class AuthService extends ChangeNotifier implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _errorMessage;

  AuthService() {
    _auth.authStateChanges().listen((u) {
      _user = u;
      if (u != null) {
        // Fire-and-forget: keep Firestore user doc present even across app restarts.
        _ensureUserDocument(
          uid: u.uid,
          name: u.displayName ?? '',
          email: u.email ?? '',
          phone: u.phoneNumber ?? '',
          profileImage: u.photoURL,
        );
      }
      notifyListeners();
    });
  }

  @override
  Stream<User?> get userChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _user;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      _errorMessage = null;
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      if (_user != null) {
        await _ensureUserDocument(
          uid: _user!.uid,
          name: _user!.displayName ?? '',
          email: _user!.email ?? email,
          phone: _user!.phoneNumber ?? '',
          profileImage: _user!.photoURL,
        );
      }
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء تسجيل الدخول';
      notifyListeners();
      return null;
    }
  }

  @override
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      _errorMessage = null;
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;

      if (_user != null) {
        await _user!.updateDisplayName(name);
        await _user!.reload();
        _user = _auth.currentUser;
        await _ensureUserDocument(
          uid: _user!.uid,
          name: name,
          email: _user!.email ?? email,
          phone: phone,
          profileImage: _user!.photoURL,
        );
      }

      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء إنشاء الحساب';
      notifyListeners();
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تسجيل الخروج';
      notifyListeners();
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      _errorMessage = null;

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // Sign out first to show account selection.
      await googleSignIn.signOut();

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        _errorMessage = 'فشل الحصول على بيانات Google';
        notifyListeners();
        return null;
      }

      final authz = await googleUser.authorizationClient.authorizeScopes(const [
        'email',
        'profile',
      ]);

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authz.accessToken,
      );

      final result = await _auth.signInWithCredential(credential);
      _user = result.user;
      if (_user != null) {
        await _ensureUserDocument(
          uid: _user!.uid,
          name: _user!.displayName ?? '',
          email: _user!.email ?? '',
          phone: _user!.phoneNumber ?? '',
          profileImage: _user!.photoURL,
        );
      }
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } on GoogleSignInException catch (e) {
      _errorMessage = e.code == GoogleSignInExceptionCode.canceled
          ? 'تم إلغاء تسجيل الدخول'
          : 'خطأ في تسجيل الدخول عبر Google: ${e.description ?? e.code}';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'خطأ في تسجيل الدخول عبر Google: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        _errorMessage = 'كلمة المرور ضعيفة جداً (يجب أن تكون 6 أحرف على الأقل)';
        break;
      case 'email-already-in-use':
        _errorMessage = 'البريد الإلكتروني مستخدم بالفعل. حاول تسجيل الدخول';
        break;
      case 'invalid-email':
        _errorMessage = 'البريد الإلكتروني غير صحيح';
        break;
      case 'user-disabled':
        _errorMessage = 'هذا الحساب معطل. تواصل مع الدعم';
        break;
      case 'user-not-found':
        _errorMessage = 'لا يوجد حساب بهذا البريد الإلكتروني';
        break;
      case 'wrong-password':
        _errorMessage = 'كلمة المرور غير صحيحة';
        break;
      case 'operation-not-allowed':
        _errorMessage = 'هذه الطريقة غير مفعلة. تفعلها من لوحة Firebase';
        break;
      case 'too-many-requests':
        _errorMessage = 'محاولات كثيرة جداً. حاول لاحقاً';
        break;
      case 'network-request-failed':
        _errorMessage = 'خطأ في الاتصال بالإنترنت';
        break;
      default:
        _errorMessage = e.message ?? 'حدث خطأ: ${e.code}';
    }
    notifyListeners();
  }

  Future<void> _ensureUserDocument({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String? profileImage,
  }) async {
    if (uid.trim().isEmpty) return;

    final users = FirebaseFirestore.instance.collection('users');
    final ref = users.doc(uid);
    final snap = await ref.get();

    final Map<String, dynamic> updates = {};

    if (!snap.exists || snap.data() == null) {
      updates.addAll({
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': profileImage,
        'friends': <String>[],
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      final data = snap.data();
      if (data is Map<String, dynamic>) {
        // Migrate legacy schema: `friends` incorrectly stored as a map of profile fields.
        final legacy = data['friends'];
        if (legacy is Map) {
          updates['legacyProfile'] = Map<String, dynamic>.from(legacy);
          updates['friends'] = <String>[];
        }

        final existingName = data['name'];
        if ((existingName is! String || existingName.trim().isEmpty) &&
            name.trim().isNotEmpty) {
          updates['name'] = name;
        }

        final existingEmail = data['email'];
        if ((existingEmail is! String || existingEmail.trim().isEmpty) &&
            email.trim().isNotEmpty) {
          updates['email'] = email;
        }

        final existingPhone = data['phone'];
        if ((existingPhone is! String || existingPhone.trim().isEmpty) &&
            phone.trim().isNotEmpty) {
          updates['phone'] = phone;
        }

        final existingProfileImage = data['profileImage'];
        if ((existingProfileImage is! String ||
                existingProfileImage.trim().isEmpty) &&
            (profileImage ?? '').trim().isNotEmpty) {
          updates['profileImage'] = profileImage;
        }
      }
    }

    updates['lastSeenAt'] = FieldValue.serverTimestamp();

    await ref.set(updates, SetOptions(merge: true));
  }
}
