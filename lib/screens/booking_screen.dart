import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korateem/features/user/data/repositories/user_repository.dart';
import 'package:korateem/models/team_model.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:korateem/services/booking_service.dart';
import 'package:korateem/services/team_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final String stadiumId;
  const BookingScreen({super.key, required this.stadiumId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final bookingService = BookingService();
  final teamService = TeamService();
  final userRepository = UserRepository();

  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  int _durationHours = 1;
  String? _teamId;
  String? _opponentTeamId;
  String _phone = '';

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    if (uid == null || uid.trim().isEmpty) return;
    try {
      final u = await userRepository.getUser(uid);
      if (!mounted) return;
      setState(() => _phone = u.phone);
    } catch (_) {
      // Optional; phone may be missing for legacy users.
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthService>(context).currentUser?.uid ?? '';
    if (uid.trim().isEmpty) {
      return const Scaffold(
        body: Center(child: Text('سجل الدخول أولاً لإتمام الحجز')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('حجز الملعب'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('اختر التاريخ'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildSectionTitle('اختر فريقك'),
              const SizedBox(height: 12),
              _buildTeamPickers(uid),
              const SizedBox(height: 20),
              _buildSectionTitle('اختر الوقت'),
              const SizedBox(height: 12),
              _buildTimeSlots(),
              const SizedBox(height: 20),
              _buildSectionTitle('مدة الحجز'),
              const SizedBox(height: 12),
              _buildDurationPicker(),
              const SizedBox(height: 24),
              _buildBookingButton(uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF404040)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1E1E),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'التاريخ المختار',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE، d MMMM y', 'ar').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Widget _buildTeamPickers(String uid) {
    return StreamBuilder(
      stream: teamService.getTeamsForUser(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        final myTeams = docs.map((d) => TeamModel.fromFirestore(d)).toList();
        if (myTeams.isEmpty) {
          return const Text(
            'لازم يكون عندك فريق قبل الحجز. روح لصفحة "الفرق" واعمل فريق.',
            textAlign: TextAlign.right,
          );
        }

        return StreamBuilder(
          stream: teamService.getTeams(),
          builder: (context, allSnapshot) {
            if (!allSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final allTeams = allSnapshot.data!.docs
                .map((d) => TeamModel.fromFirestore(d))
                .where((t) => t.teamId.isNotEmpty)
                .toList();

            return Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _teamId,
                  items: myTeams
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.teamId,
                          child: Text(t.name, textAlign: TextAlign.right),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() {
                    _teamId = v;
                    if (_opponentTeamId == v) _opponentTeamId = null;
                  }),
                  decoration: const InputDecoration(
                    labelText: 'فريقك',
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _opponentTeamId,
                  items: allTeams
                      .where((t) => t.teamId != _teamId)
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.teamId,
                          child: Text(t.name, textAlign: TextAlign.right),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _opponentTeamId = v),
                  decoration: const InputDecoration(
                    labelText: 'الفريق المنافس',
                    prefixIcon: Icon(Icons.sports_kabaddi),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimeSlots() {
    final timeSlots = [
      '06:00',
      '07:00',
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
      '22:00',
      '23:00',
    ];

    final end = _selectedSlot == null
        ? null
        : _computeEndTime(_selectedSlot!, _durationHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeSlots.map((slot) {
            final selected = _selectedSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: selected,
              onSelected: (_) => setState(() => _selectedSlot = slot),
            );
          }).toList(),
        ),
        if (end != null) ...[
          const SizedBox(height: 10),
          Text(
            'وقت الانتهاء: $end',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildDurationPicker() {
    return DropdownButtonFormField<int>(
      initialValue: _durationHours,
      items: [1, 2, 3, 4]
          .map(
            (h) => DropdownMenuItem(
              value: h,
              child: Text('$h ساعة', textAlign: TextAlign.right),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _durationHours = v ?? 1),
      decoration: const InputDecoration(
        labelText: 'عدد الساعات',
        prefixIcon: Icon(Icons.timelapse_rounded),
      ),
    );
  }

  Widget _buildBookingButton(String uid) {
    final isValid = _selectedSlot != null &&
        _teamId != null &&
        _opponentTeamId != null &&
        _durationHours >= 1;
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: (!isValid || _saving) ? null : () => _confirmBooking(uid),
        child: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('تأكيد الحجز'),
      ),
    );
  }

  Future<void> _confirmBooking(String uid) async {
    final slot = _selectedSlot;
    final teamId = _teamId;
    final opponentTeamId = _opponentTeamId;
    if (slot == null || teamId == null || opponentTeamId == null) return;
    final endTime = _computeEndTime(slot, _durationHours);
    if (endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('مدة الحجز غير صالحة (تتجاوز منتصف الليل)'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // Enforce stadium schedule (defaults to 24/7 if missing).
      final stadiumDoc = await FirebaseFirestore.instance
          .collection('stadiums')
          .doc(widget.stadiumId)
          .get();
      final stadiumData = stadiumDoc.data();
      final schedule = (stadiumData?['schedule'] is Map)
          ? Map<String, dynamic>.from(stadiumData?['schedule'] as Map)
          : <String, dynamic>{};
      for (var i = 0; i < _durationHours; i++) {
        final current = _addHours(slot, i);
        if (!_isSlotAllowed(schedule, current)) {
          throw Exception('الملعب غير متاح في هذا الوقت حسب جدول المالك');
        }
      }

      // Resolve team names from Firestore snapshots (read once).
      final myTeamsSnap = await teamService.getTeamsForUser(uid).first;
      final allTeamsSnap = await teamService.getTeams().first;
      final myTeams = myTeamsSnap.docs.map((d) => TeamModel.fromFirestore(d)).toList();
      final allTeams = allTeamsSnap.docs.map((d) => TeamModel.fromFirestore(d)).toList();

      final myTeam = myTeams.firstWhere((t) => t.teamId == teamId);
      final oppTeam = allTeams.firstWhere((t) => t.teamId == opponentTeamId);
      final stadiumName = (stadiumData?['name'] ?? 'Stadium').toString();

      await bookingService.createBooking(
        stadiumId: widget.stadiumId,
        stadiumName: stadiumName,
        userId: uid,
        teamId: myTeam.teamId,
        teamName: myTeam.name,
        opponentTeamId: oppTeam.teamId,
        opponentTeamName: oppTeam.name,
        teamMemberIds: myTeam.memberIds,
        teamCaptainId: myTeam.captainId,
        opponentMemberIds: oppTeam.memberIds,
        opponentCaptainId: oppTeam.captainId,
        date: _selectedDate,
        time: slot,
        durationHours: _durationHours,
        endTime: endTime,
        phone: _phone,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الحجز للمالك (قيد المراجعة)'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: const Color(0xFFCF6679),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isSlotAllowed(Map<String, dynamic> schedule, String slot) {
    final mode = (schedule['mode'] ?? '').toString().trim().toLowerCase();
    if (mode.isEmpty || mode == '24_7') return true;
    if (mode != 'hours') return true;

    int? toMinutes(String v) {
      final parts = v.split(':');
      if (parts.length != 2) return null;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) return null;
      return (h.clamp(0, 23) * 60) + m.clamp(0, 59);
    }

    final open = toMinutes((schedule['open'] ?? '00:00').toString()) ?? 0;
    final close = toMinutes((schedule['close'] ?? '23:59').toString()) ?? 23 * 60 + 59;
    final t = toMinutes(slot);
    if (t == null) return true;
    if (close >= open) return t >= open && t <= close;
    // Overnight range (e.g. 20:00 -> 02:00): allow if after open OR before close.
    return t >= open || t <= close;
  }

  String _addHours(String slot, int add) {
    final parts = slot.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final next = h * 60 + m + (add * 60);
    final nh = (next ~/ 60) % 24;
    final nm = next % 60;
    return '${nh.toString().padLeft(2, '0')}:${nm.toString().padLeft(2, '0')}';
  }

  String? _computeEndTime(String start, int durationHours) {
    final parts = start.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final startMinutes = h * 60 + m;
    final endMinutes = startMinutes + (durationHours * 60);
    if (endMinutes > 24 * 60) return null; // don't allow crossing midnight
    final eh = (endMinutes ~/ 60) % 24;
    final em = endMinutes % 60;
    return '${eh.toString().padLeft(2, '0')}:${em.toString().padLeft(2, '0')}';
  }
}
