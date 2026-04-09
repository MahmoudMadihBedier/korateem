import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:korateem/services/owner_service.dart';
import 'package:korateem/ui/modern_components.dart';

class StadiumBookingsReviewPage extends StatefulWidget {
  final String stadiumId;
  final String stadiumName;

  const StadiumBookingsReviewPage({
    super.key,
    required this.stadiumId,
    required this.stadiumName,
  });

  @override
  State<StadiumBookingsReviewPage> createState() =>
      _StadiumBookingsReviewPageState();
}

class _StadiumBookingsReviewPageState extends State<StadiumBookingsReviewPage> {
  final OwnerService _ownerService = OwnerService();

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'accepted':
      case 'waiting_payment':
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
    switch (status.trim().toLowerCase()) {
      case 'accepted':
        return 'تم الحجز';
      case 'waiting_payment':
        return 'بانتظار الدفع';
      case 'rejected':
        return 'مرفوض';
      case 'canceled':
        return 'ملغي';
      default:
        return 'قيد المراجعة';
    }
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    if (value is String) return value;
    return '—';
  }

  Future<void> _promptReject(BuildContext context, String bookingId) async {
    String reasonText = '';
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(dialogContext).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'سبب الرفض',
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  onChanged: (v) => setState(() => reasonText = v),
                  decoration: const InputDecoration(
                    hintText: 'اكتب سبب الرفض...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, reasonText.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCF6679),
                        ),
                        child: const Text('رفض'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final trimmed = (reason ?? '').trim();
    if (trimmed.isEmpty) return;
    await _ownerService.rejectBooking(bookingId, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(
        title: 'حجوزات ${widget.stadiumName}',
        showNotification: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ownerService.getBookings(widget.stadiumId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ModernLoading();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'لا توجد طلبات',
              subtitle: 'لم يتم إنشاء حجوزات لهذا الملعب بعد',
            );
          }

          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final ma = (a.data() as Map<String, dynamic>);
            final mb = (b.data() as Map<String, dynamic>);
            final sa = (ma['status'] ?? 'pending').toString().toLowerCase();
            final sb = (mb['status'] ?? 'pending').toString().toLowerCase();
            // Pending first.
            int rank(String s) => s == 'pending' ? 0 : 1;
            final r = rank(sa).compareTo(rank(sb));
            if (r != 0) return r;
            final ta = ma['createdAt'];
            final tb = mb['createdAt'];
            final da = ta is Timestamp ? ta.toDate() : DateTime(1970);
            final db = tb is Timestamp ? tb.toDate() : DateTime(1970);
            return db.compareTo(da);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final bookingId = doc.id;
              final data = doc.data() as Map<String, dynamic>;

              final status = (data['status'] ?? 'pending').toString();
              final paymentScreenshotUrl = data['paymentScreenshotUrl'] as String?;
              final paymentStatus = data['paymentStatus'] as String?;
              final statusColor = _statusColor(status);
              final dateLabel = _formatDate(data['date']);
              final time = (data['time'] ?? '—').toString();
              final endTime = (data['endTime'] ?? '').toString();
              final duration = data['durationHours'];
              final durationLabel = duration is num ? '${duration.toInt()}س' : '';
              final phone = (data['phone'] ?? '').toString();
              final team = (data['teamName'] ?? 'فريق').toString();
              final opp = (data['opponentTeamName'] ?? 'فريق').toString();
              final rejectionReason =
                  (data['rejectionReason'] ?? '').toString().trim();
              final canceledIds = (data['canceledParticipantIds'] is List)
                  ? List<String>.from(data['canceledParticipantIds'] as List)
                  : <String>[];

              return ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
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
                            _statusLabel(status),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$dateLabel • $time${endTime.isEmpty ? '' : ' - $endTime'} ${durationLabel.isEmpty ? '' : '($durationLabel)'}',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$team vs $opp',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.right,
                    ),
                    if (canceledIds.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'انسحب ${canceledIds.length} لاعب من المشاركة',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCF6679),
                            ),
                      ),
                    ],
                    if (paymentScreenshotUrl != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (paymentStatus == 'submitted')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('تم الرفع', style: TextStyle(color: Colors.blue, fontSize: 10)),
                            ),
                          const Text(
                            'إثبات الدفع:',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(paymentScreenshotUrl),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إغلاق'),
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
                          ),
                        ),
                      ),
                    ],
                    if (phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Color(0xFF66BB6A)),
                          const SizedBox(width: 8),
                          Text(phone, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                    if (status.toLowerCase() == 'rejected' &&
                        rejectionReason.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'سبب الرفض: $rejectionReason',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFCF6679),
                            ),
                      ),
                    ],
                    if (status.toLowerCase() == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _promptReject(context, bookingId),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFCF6679),
                                side: const BorderSide(color: Color(0xFFCF6679)),
                              ),
                              child: const Text('رفض'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _ownerService.acceptBooking(bookingId),
                              child: const Text('قبول'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
