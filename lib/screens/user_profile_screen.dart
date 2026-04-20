import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:korateem/services/booking_service.dart';
import 'package:korateem/services/user_service.dart';
import 'package:korateem/services/field_service.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:image_picker/image_picker.dart';
import 'package:korateem/features/stadium/data/models/stadium_model.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userService.getUserProfile(widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: ModernLoading());
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: EmptyState(
              icon: Icons.error_outline,
              title: 'تعذر تحميل الملف',
              subtitle: snapshot.error.toString(),
            ),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.person_outline,
              title: 'الملف غير متاح',
              subtitle: 'لم يتم العثور على بيانات المستخدم',
            ),
          );
        }

        final name = (data['name'] ?? data['displayName'] ?? 'مستخدم').toString();
        final email = (data['email'] ?? '').toString();
        final phone = (data['phone'] ?? '').toString();
        final ratingRaw = data['rating'];
        final rating = (ratingRaw is num) ? ratingRaw.toDouble() : 0.0;
        final profileImage = (data['profileImage'] ?? data['photoURL'] ?? '')
            .toString()
            .trim();
        final friends = data['friends'];
        final friendsCount = (friends is List) ? friends.length : 0;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 320,
                    title: const Text('حسابي'),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/studim.jpeg',
                            fit: BoxFit.cover,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.55),
                                  Colors.black.withOpacity(0.25),
                                  Theme.of(context).scaffoldBackgroundColor,
                                ],
                                stops: const [0, 0.6, 1],
                              ),
                            ),
                          ),
                          SafeArea(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  84,
                                ),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 650),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, t, child) => Opacity(
                                    opacity: t,
                                    child: Transform.translate(
                                      offset: Offset(0, 12 * (1 - t)),
                                      child: child,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _ProfileAvatar(
                                        imageUrl: profileImage,
                                        fallbackText:
                                            name.isNotEmpty ? name[0] : 'U',
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      if (phone.isNotEmpty)
                                        Text(
                                          phone,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white70),
                                          textAlign: TextAlign.center,
                                        )
                                      else if (email.isNotEmpty)
                                        Text(
                                          email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white70),
                                          textAlign: TextAlign.center,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottom: const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'نظرة عامة'),
                        Tab(text: 'المعلومات'),
                        Tab(text: 'النشاط'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _OverviewTab(
                    uid: widget.uid,
                    rating: rating,
                    friendsCount: friendsCount,
                  ),
                  _InfoTab(email: email, phone: phone),
                  _ActivityTab(uid: widget.uid),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String fallbackText;

  const _ProfileAvatar({required this.imageUrl, required this.fallbackText});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
        child: hasImage
            ? null
            : Text(
                fallbackText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String uid;
  final double rating;
  final int friendsCount;

  const _OverviewTab({
    required this.uid,
    required this.rating,
    required this.friendsCount,
  });

  @override
  Widget build(BuildContext context) {
    final clampedRating = rating.clamp(0.0, 5.0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    clampedRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'تقييمك',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(5, (index) {
                  final filled = index < clampedRating.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFFA500),
                    size: 22,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ModernCard(
                child: _Stat(
                  label: 'الأصدقاء',
                  value: friendsCount.toString(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernCard(
                child: const _Stat(label: 'الحجوزات', value: '—'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ModernCard(
          onTap: () => Navigator.pushNamed(
            context,
            '/user-profile-edit',
            arguments: {'userId': uid},
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'تعديل الملف',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حدّث بياناتك وصورتك',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _InfoTab extends StatelessWidget {
  final String email;
  final String phone;

  const _InfoTab({required this.email, required this.phone});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'بيانات الحساب',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'البريد الإلكتروني',
                value: email.isEmpty ? '—' : email,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'رقم الهاتف',
                value: phone.isEmpty ? '—' : phone,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}

class _ActivityTab extends StatefulWidget {
  final String uid;
  const _ActivityTab({required this.uid});

  @override
  State<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<_ActivityTab> {
  final BookingService _bookingService = BookingService();
  final _controller = StreamController<List<QueryDocumentSnapshot>>.broadcast();

  StreamSubscription<QuerySnapshot>? _subUser;
  StreamSubscription<QuerySnapshot>? _subParticipant;

  Map<String, QueryDocumentSnapshot> _userDocs = {};
  Map<String, QueryDocumentSnapshot> _participantDocs = {};

  bool _readyUser = false;
  bool _readyParticipant = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final col = FirebaseFirestore.instance.collection('bookings');

    _subUser = col.where('userId', isEqualTo: widget.uid).snapshots().listen(
      (snap) {
        _readyUser = true;
        _userDocs = {for (final d in snap.docs) d.id: d};
        _emit();
      },
      onError: (e) {
        _readyUser = true;
        _error = e;
        _emit();
      },
    );

    _subParticipant =
        col.where('participantIds', arrayContains: widget.uid).snapshots().listen(
      (snap) {
        _readyParticipant = true;
        _participantDocs = {for (final d in snap.docs) d.id: d};
        _emit();
      },
      onError: (e) {
        _readyParticipant = true;
        _error = e;
        _emit();
      },
    );
  }

  void _emit() {
    if (!(_readyUser && _readyParticipant)) return;
    if (_error != null) {
      _controller.addError(_error!);
      return;
    }
    final merged = <String, QueryDocumentSnapshot>{};
    merged.addAll(_userDocs);
    merged.addAll(_participantDocs);

    final docs = merged.values.toList();
    docs.sort((a, b) {
      DateTime readCreated(QueryDocumentSnapshot d) {
        final data = d.data() as Map<String, dynamic>;
        final ts = data['createdAt'];
        if (ts is Timestamp) return ts.toDate();
        final date = data['date'];
        if (date is Timestamp) return date.toDate();
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      return readCreated(b).compareTo(readCreated(a));
    });
    _controller.add(docs);
  }

  @override
  void dispose() {
    _subUser?.cancel();
    _subParticipant?.cancel();
    _controller.close();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
      case 'confirmed':
        return const Color(0xFF43A047);
      case 'waiting_payment':
        return const Color(0xFF2196F3);
      case 'payment_submitted':
        return const Color(0xFF9C27B0);
      case 'rejected':
        return const Color(0xFFCF6679);
      case 'canceled':
        return const Color(0xFF808080);
      default:
        return const Color(0xFFFFA500);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
      case 'confirmed':
        return 'مقبول';
      case 'waiting_payment':
        return 'بانتظار الدفع';
      case 'payment_submitted':
        return 'تم دفع العربون';
      case 'rejected':
        return 'مرفوض';
      case 'canceled':
        return 'ملغي';
      default:
        return 'قيد المراجعة';
    }
  }

  Future<void> _showPaymentDialog(
    BuildContext context, {
    required String bookingId,
    required String stadiumId,
  }) async {
    final fieldService = FieldService();
    final bookingService = BookingService();
    final picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FutureBuilder<DocumentSnapshot>(
        future: fieldService.getField(stadiumId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ModernLoading());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: const Text('خطأ', textAlign: TextAlign.right),
              content: const Text('تعذر تحميل بيانات الملعب',
                  textAlign: TextAlign.right),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          }

          final stadium = StadiumModel.fromFirestore(
              snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

          String? selectedPaymentMethod;

          XFile? selectedImage;
          bool uploading = false;

          return StatefulBuilder(
            builder: (context, setState) {
              final image = selectedImage;

              return Dialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'دفع الرسوم - ${stadium.name}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'خيارات الدفع المتاحة:',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Color(0xFF43A047),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (stadium.instapayNumber != null && stadium.instapayNumber!.isNotEmpty)
                        ListTile(
                          title: Text('إنستا باي: ${stadium.instapayNumber}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: Radio<String>(
                            value: 'InstaPay',
                            groupValue: selectedPaymentMethod,
                            onChanged: (v) => setState(() => selectedPaymentMethod = v),
                            activeColor: const Color(0xFF43A047),
                          ),
                          onTap: () => setState(() => selectedPaymentMethod = 'InstaPay'),
                        ),
                      if (stadium.vodafoneCashNumber != null && stadium.vodafoneCashNumber!.isNotEmpty)
                        ListTile(
                          title: Text('فودافون كاش: ${stadium.vodafoneCashNumber}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: Radio<String>(
                            value: 'Vodafone Cash',
                            groupValue: selectedPaymentMethod,
                            onChanged: (v) => setState(() => selectedPaymentMethod = v),
                            activeColor: const Color(0xFF43A047),
                          ),
                          onTap: () => setState(() => selectedPaymentMethod = 'Vodafone Cash'),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'قم بتحميل لقطة شاشة لإثبات الدفع:',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final img = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (img != null) {
                            setState(() => selectedImage = img);
                          }
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: image == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 40, color: Color(0xFF43A047)),
                                    SizedBox(height: 8),
                                    Text('إختر صورة',
                                        style:
                                          TextStyle(color: Color(0xFF43A047))),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(image.path),
                                      fit: BoxFit.cover),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (image == null || uploading)
                                  ? null
                                  : () async {
                                      setState(() => uploading = true);
                                      try {
                                        final String fileName = 'payment_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                        final ref = FirebaseStorage.instance
                                            .ref()
                                            .child('payment_screenshots')
                                            .child(fileName);
                                        await ref.putFile(
                                          File(image.path),
                                          SettableMetadata(
                                            contentType: 'image/jpeg',
                                          ),
                                        );
                                        final downloadUrl =
                                            await ref.getDownloadURL();
                                        await bookingService.uploadPaymentScreenshot(
                                          bookingId: bookingId,
                                          screenshotUrl: downloadUrl,
                                          method: selectedPaymentMethod,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم رفع إثبات الدفع بنجاح')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('خطأ: $e')),
                                          );
                                        }
                                      } finally {
                                        if (context.mounted) setState(() => uploading = false);
                                      }
                                    },
                              child: uploading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('تأكيد الدفع'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _promptCancel(
    BuildContext context, {
    required String bookingId,
    required String userId,
  }) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'سبب الإلغاء',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'اكتب سبب الإلغاء...',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('رجوع'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF6679),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final r = (reason ?? '').trim();
    if (r.isEmpty) return;
    await _bookingService.cancelParticipation(
      bookingId: bookingId,
      userId: userId,
      reason: r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (!(_readyUser && _readyParticipant)) {
          return const ModernLoading();
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: EmptyState(
              icon: Icons.error_outline,
              title: 'تعذر تحميل الحجوزات',
              subtitle: 'تحقق من صلاحيات Firebase أو قواعد Firestore.',
            ),
          );
        }

        final docs = snapshot.data ?? const [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: EmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'لا توجد حجوزات بعد',
              subtitle: 'ابدأ بحجز ملعب من صفحة الملاعب.',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bookingId = doc.id;

            final stadiumName = (data['stadiumName'] ?? 'ملعب').toString();
            final teamName = (data['teamName'] ?? 'فريق').toString();
            final opponent = (data['opponentTeamName'] ?? 'فريق').toString();
            final time = (data['time'] ?? '').toString();
            final endTime = (data['endTime'] ?? '').toString();
            final status = (data['status'] ?? 'pending').toString();
            final paymentScreenshotUrl = (data['paymentScreenshotUrl'] ?? '').toString();
            final rejectionReason =
                (data['rejectionReason'] ?? '').toString().trim();

            final date = data['date'];
            final dateText = date is Timestamp ? date.toDate() : null;
            final dateLabel = dateText == null
                ? '—'
                : '${dateText.year}-${dateText.month.toString().padLeft(2, '0')}-${dateText.day.toString().padLeft(2, '0')}';

            final teamMembers = (data['teamMemberIds'] is List)
                ? List<String>.from(data['teamMemberIds'] as List)
                : <String>[];
            final oppMembers = (data['opponentMemberIds'] is List)
                ? List<String>.from(data['opponentMemberIds'] as List)
                : <String>[];
            final teamCaptainId = (data['teamCaptainId'] ?? '').toString();
            final oppCaptainId = (data['opponentCaptainId'] ?? '').toString();

            final isTeamMember = teamMembers.contains(widget.uid);
            final isOppMember = oppMembers.contains(widget.uid);
            final captainForMe =
                isTeamMember ? teamCaptainId : (isOppMember ? oppCaptainId : '');
            final isCaptain = captainForMe.isNotEmpty && captainForMe == widget.uid;

            final canceledIds = (data['canceledParticipantIds'] is List)
                ? List<String>.from(data['canceledParticipantIds'] as List)
                : <String>[];
            final alreadyCanceled = canceledIds.contains(widget.uid);

            String myCancelReason() {
              final list = data['cancellations'];
              if (list is! List) return '';
              for (final item in list) {
                if (item is Map && item['userId']?.toString() == widget.uid) {
                  return (item['reason'] ?? '').toString().trim();
                }
              }
              return '';
            }

            final normalizedStatus = status.toLowerCase();
            final canCancel = !alreadyCanceled &&
                !isCaptain &&
                (isTeamMember || isOppMember) &&
                (normalizedStatus == 'pending' ||
                    normalizedStatus == 'accepted' ||
                    normalizedStatus == 'approved' ||
                    normalizedStatus == 'confirmed');

            final statusColor = _statusColor(status);
            final statusLabel = _statusLabel(status);
            final reason = myCancelReason();

            final canPay = normalizedStatus == 'waiting_payment' && isCaptain;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.stadium_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                stadiumName,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$teamName vs $opponent',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            statusLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      endTime.isEmpty ? time : '$time - $endTime',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (paymentScreenshotUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'إيصال الدفع:',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(10),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Center(
                                    child: InteractiveViewer(
                                      child: Image.network(paymentScreenshotUrl),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            paymentScreenshotUrl,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 100,
                              width: 100,
                              color: Colors.white10,
                              child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (alreadyCanceled) ...[
                      const SizedBox(height: 10),
                      Text(
                        reason.isEmpty ? 'انسحبت من هذا الحجز' : 'انسحبت: $reason',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCF6679),
                            ),
                      ),
                    ],
                    if (normalizedStatus == 'rejected' &&
                        rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'سبب الرفض: $rejectionReason',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCF6679),
                            ),
                      ),
                    ],
                    if (canPay) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => _showPaymentDialog(
                            context,
                            bookingId: bookingId,
                            stadiumId: data['stadiumId'] ?? '',
                          ),
                          icon: const Icon(Icons.payment_outlined),
                          label: const Text('دفع الرسوم (العربون)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (canCancel) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () => _promptCancel(
                            context,
                            bookingId: bookingId,
                            userId: widget.uid,
                          ),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('إلغاء مشاركتي'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFCF6679),
                            side: const BorderSide(color: Color(0xFFCF6679)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
