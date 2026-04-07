import 'package:flutter/material.dart';

class MatchFilterBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> countries;
  final List<Map<String, dynamic>> leagues;
  final Function(String? country, int? league, String? status) onApply;

  const MatchFilterBottomSheet({
    super.key,
    required this.countries,
    required this.leagues,
    required this.onApply,
  });

  @override
  State<MatchFilterBottomSheet> createState() => _MatchFilterBottomSheetState();
}

class _MatchFilterBottomSheetState extends State<MatchFilterBottomSheet> {
  String? _selectedCountry;
  int? _selectedLeague;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'تصفية المباريات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Country Dropdown
          const Text('الدولة', style: TextStyle(color: Colors.grey)),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedCountry,
            dropdownColor: const Color(0xFF2A2A2A),
            items: [
              const DropdownMenuItem(value: null, child: Text('الكل', textAlign: TextAlign.right)),
              ...widget.countries.map((c) => DropdownMenuItem(
                value: c['name'],
                child: Text(c['name'] ?? '', textAlign: TextAlign.right),
              )),
            ],
            onChanged: (v) => setState(() {
              _selectedCountry = v;
              _selectedLeague = null;
            }),
          ),
          const SizedBox(height: 16),

          // League Dropdown
          const Text('البطولة', style: TextStyle(color: Colors.grey)),
          DropdownButton<int>(
            isExpanded: true,
            value: _selectedLeague,
            dropdownColor: const Color(0xFF2A2A2A),
            items: [
              const DropdownMenuItem(value: null, child: Text('الكل', textAlign: TextAlign.right)),
              ...widget.leagues
                  .where((l) => _selectedCountry == null || l['country'] == _selectedCountry)
                  .map((l) => DropdownMenuItem(
                value: l['id'],
                child: Text(l['name'] ?? '', textAlign: TextAlign.right),
              )),
            ],
            onChanged: (v) => setState(() => _selectedLeague = v),
          ),
          const SizedBox(height: 16),

          // Status Dropdown
          const Text('الحالة', style: TextStyle(color: Colors.grey)),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedStatus,
            dropdownColor: const Color(0xFF2A2A2A),
            items: const [
              DropdownMenuItem(value: null, child: Text('الكل', textAlign: TextAlign.right)),
              DropdownMenuItem(value: 'LIVE', child: Text('مباشر', textAlign: TextAlign.right)),
              DropdownMenuItem(value: 'NS', child: Text('لم تبدأ', textAlign: TextAlign.right)),
              DropdownMenuItem(value: 'FT', child: Text('انتهت', textAlign: TextAlign.right)),
            ],
            onChanged: (v) => setState(() => _selectedStatus = v),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedCountry, _selectedLeague, _selectedStatus);
                Navigator.pop(context);
              },
              child: const Text('تطبيق التصفية'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
