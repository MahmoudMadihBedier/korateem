import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/stadium_repository.dart';
import '../../domain/entities/stadium_entity.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:korateem/screens/booking_screen.dart';

class FieldsPage extends StatefulWidget {
  const FieldsPage({super.key});

  @override
  State<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends State<FieldsPage> {
  final searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  ImageProvider _photoProvider(String value) {
    final v = value.trim();
    if (v.isEmpty) return const AssetImage('assets/images/studim.jpeg');
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }
    try {
      final cleaned = v.startsWith('data:image')
          ? v.substring(v.indexOf('base64,') + 'base64,'.length)
          : v;
      final bytes = base64Decode(cleaned);
      return MemoryImage(bytes);
    } catch (_) {
      return const AssetImage('assets/images/studim.jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stadiumRepo = Provider.of<IStadiumRepository>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(
        title: 'الملاعب المتاحة',
        showNotification: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن ملعب...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF43A047)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<StadiumEntity>>(
              stream: stadiumRepo.watchAllStadiums(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ModernLoading();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyState(
                    icon: Icons.sports_soccer,
                    title: 'لا توجد ملاعب متاحة',
                  );
                }

                final fields = snapshot.data!.where((field) {
                  return field.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return AnimatedListItem(
                      delay: Duration(milliseconds: index * 50),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StadiumCard(
                          name: field.name,
                          location: field.address ?? 'غير محدد',
                          rating: field.rating,
<<<<<<< feat/match-schedule-15652955682575042549
                          price: field.pricePerHour.toStringAsFixed(0),
=======
                          price: '100', // Example price
>>>>>>> dev
                          onTap: () => _showFieldDetails(context, field),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFieldDetails(BuildContext context, StadiumEntity field) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: _photoProvider(field.photos.isNotEmpty ? field.photos.first : ''),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              field.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⭐ ${field.rating}',
                    style: const TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  field.address ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              field.description,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
<<<<<<< feat/match-schedule-15652955682575042549
            const SizedBox(height: 12),
            Text(
              'السعر: ${field.pricePerHour.toStringAsFixed(0)} ج.م / ساعة',
              style: const TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
=======
>>>>>>> dev
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingScreen(stadiumId: field.id)),
                );
              },
              child: const Text('احجز الآن'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
