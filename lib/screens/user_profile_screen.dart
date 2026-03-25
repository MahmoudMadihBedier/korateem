import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korateem/services/booking_service.dart';
import 'package:korateem/services/user_service.dart';
import 'package:korateem/ui/modern_components.dart';

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
      case 'rejected':
        return 'مرفوض';
      case 'canceled':
        return 'ملغي';
      default:
        return 'قيد المراجعة';
    }
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
    controller.dispose();
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
