import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:korateem/ui/modern_components.dart';

class StadiumPhotosPage extends StatefulWidget {
  final String stadiumId;
  final String stadiumName;

  const StadiumPhotosPage({
    super.key,
    required this.stadiumId,
    required this.stadiumName,
  });

  @override
  State<StadiumPhotosPage> createState() => _StadiumPhotosPageState();
}

class _StadiumPhotosPageState extends State<StadiumPhotosPage> {
  static const int _maxPhotos = 6;
  final _picker = ImagePicker();

  bool _saving = false;

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

  Future<void> _addPhotos(List<String> current) async {
    if (_saving) return;
    if (current.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('وصلت للحد الأقصى للصور'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }

    final files = await _picker.pickMultiImage(
      maxWidth: 1280,
      imageQuality: 60,
    );
    if (files.isEmpty) return;

    setState(() => _saving = true);
    try {
      final remaining = (_maxPhotos - current.length).clamp(0, _maxPhotos);
      final selected = files.take(remaining).toList();

      final newPhotos = <String>[];
      for (final f in selected) {
        final bytes = await f.readAsBytes();
        newPhotos.add(base64Encode(bytes));
      }

      final next = [...current, ...newPhotos];
      await FirebaseFirestore.instance
          .collection('stadiums')
          .doc(widget.stadiumId)
          .set({'photos': next}, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء رفع الصور: $e'),
          backgroundColor: const Color(0xFFCF6679),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deletePhoto(List<String> current, int index) async {
    if (_saving) return;
    if (index < 0 || index >= current.length) return;
    final next = [...current]..removeAt(index);
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('stadiums')
          .doc(widget.stadiumId)
          .set({'photos': next}, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حذف الصورة: $e'),
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
      appBar: ModernAppBar(
        title: 'صور ${widget.stadiumName}',
        showNotification: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stadiums')
            .doc(widget.stadiumId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ModernLoading();
          }
          final data = snapshot.data?.data();
          final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
          final raw = map['photos'];
          final photos = raw is List ? raw.whereType<String>().toList() : <String>[];

          if (photos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.photo_library_outlined,
                title: 'لا توجد صور بعد',
                subtitle: 'أضف صور للملعب ليراها اللاعبون قبل الحجز',
                actionLabel: _saving ? '...' : 'إضافة صور',
                onAction: _saving ? null : () => _addPhotos(photos),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'الحد الأقصى: $_maxPhotos صور',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF808080)),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 128,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : () => _addPhotos(photos),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(128, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('إضافة'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.18,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final p = photos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: _photoProvider(p),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFCF6679),
                                ),
                                onPressed:
                                    _saving ? null : () => _deletePhoto(photos, index),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
