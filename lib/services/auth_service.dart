import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
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
      }

      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
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

      // Initialize Google Sign-In with proper client ID
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to show account selection
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _errorMessage = 'تم إلغاء تسجيل الدخول';
        notifyListeners();
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _errorMessage = 'فشل الحصول على بيانات Google';
        notifyListeners();
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      _user = result.user;
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
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
}
