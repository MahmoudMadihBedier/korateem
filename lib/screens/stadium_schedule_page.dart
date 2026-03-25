import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:korateem/ui/modern_components.dart';

class StadiumSchedulePage extends StatefulWidget {
  final String stadiumId;
  const StadiumSchedulePage({super.key, required this.stadiumId});

  @override
  State<StadiumSchedulePage> createState() => _StadiumSchedulePageState();
}

class _StadiumSchedulePageState extends State<StadiumSchedulePage> {
  bool _open247 = true;
  TimeOfDay _open = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _close = const TimeOfDay(hour: 23, minute: 59);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance
        .collection('stadiums')
        .doc(widget.stadiumId)
        .get();
    final data = doc.data();
    final schedule = (data?['schedule'] is Map)
        ? Map<String, dynamic>.from(data?['schedule'] as Map)
        : <String, dynamic>{};
    final mode = (schedule['mode'] ?? '24_7').toString();
    if (!mounted) return;
    setState(() {
      _open247 = mode == '24_7';
      final openStr = (schedule['open'] ?? '00:00').toString();
      final closeStr = (schedule['close'] ?? '23:59').toString();
      _open = _parse(openStr) ?? _open;
      _close = _parse(closeStr) ?? _close;
    });
  }

  TimeOfDay? _parse(String v) {
    final parts = v.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickOpen() async {
    final picked = await showTimePicker(context: context, initialTime: _open);
    if (picked != null) setState(() => _open = picked);
  }

  Future<void> _pickClose() async {
    final picked = await showTimePicker(context: context, initialTime: _close);
    if (picked != null) setState(() => _close = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final schedule = _open247
          ? <String, dynamic>{'mode': '24_7'}
          : <String, dynamic>{
              'mode': 'hours',
              'open': _fmt(_open),
              'close': _fmt(_close),
            };
      await FirebaseFirestore.instance
          .collection('stadiums')
          .doc(widget.stadiumId)
          .set({'schedule': schedule}, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الجدول'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'جدول الملعب', showNotification: false),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    value: _open247,
                    onChanged: (v) => setState(() => _open247 = v),
                    title: const Text('متاح 24/7'),
                    subtitle: const Text('إذا أغلقت الخيار، حدد ساعات العمل'),
                  ),
                  if (!_open247) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickOpen,
                            child: Text('وقت الفتح: ${_fmt(_open)}'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickClose,
                            child: Text('وقت الإغلاق: ${_fmt(_close)}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

