import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:korateem/services/auth_service.dart';
import 'package:korateem/services/user_role_service.dart';
import 'package:provider/provider.dart';

import '../ui/modern_components.dart';
import '../../services/owner_service.dart';

class StadiumProfilePage extends StatefulWidget {
  final String ownerId;
  final String? stadiumId;
  final Map<String, dynamic>? initialData;

  const StadiumProfilePage({
    super.key,
    required this.ownerId,
    this.stadiumId,
    this.initialData,
  });

  @override
  State<StadiumProfilePage> createState() => _StadiumProfilePageState();
}

class _StadiumProfilePageState extends State<StadiumProfilePage> {
  late OwnerService _ownerService;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _instapayNumberController;
  late TextEditingController _vodafoneCashNumberController;
  bool _isLoading = false;
  String? _instapayQrUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ownerService = OwnerService();
    _nameController = TextEditingController(text: widget.initialData?['name']);
    _descriptionController =
        TextEditingController(text: widget.initialData?['description']);
    _phoneController = TextEditingController(text: widget.initialData?['phone']);
    _addressController =
        TextEditingController(text: widget.initialData?['address']);
    _instapayNumberController =
        TextEditingController(text: widget.initialData?['instapayNumber']);
    _vodafoneCashNumberController =
        TextEditingController(text: widget.initialData?['vodafoneCashNumber']);
    _instapayQrUrl = widget.initialData?['instapayQr'];
  }

  Future<void> _pickQrCode() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        final file = File(image.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('stadiums/qrs/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final bytes = await image.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        final url = await ref.getDownloadURL();
        setState(() {
          _instapayQrUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading QR: $e')),
      );
    }
  }

  Future<void> _saveStadium() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'instapayNumber': _instapayNumberController.text,
        'instapayQr': _instapayQrUrl,
        'vodafoneCashNumber': _vodafoneCashNumberController.text,
      };

      if (widget.stadiumId != null) {
        await _ownerService.updateStadiumProfile(widget.stadiumId!, data);
      } else {
        await _ownerService.addStadiumProfile(widget.ownerId, {
          ...data,
          'photos': <String>[],
          'busyTimes': <Map<String, dynamic>>[],
          'freeTimes': <Map<String, dynamic>>[],
          'rating': 0.0,
          'schedule': {'mode': '24_7'},
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.stadiumId != null
                  ? 'Stadium updated successfully'
                  : 'Stadium created successfully',
            ),
            backgroundColor: const Color(0xFF43A047),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF808080)),
        prefixIcon: Icon(icon, color: const Color(0xFF43A047)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF43A047), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid =
        Provider.of<AuthService>(context, listen: false).currentUser?.uid ?? '';
    final roleService = UserRoleService();

    if (uid.trim().isEmpty || uid != widget.ownerId) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'غير مسموح',
          subtitle: 'هذه الصفحة متاحة لصاحب الملعب فقط',
        ),
      );
    }

    return StreamBuilder<String?>(
      stream: roleService.watchRole(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: ModernLoading());
        }
        final role = (snapshot.data ?? '').toLowerCase().trim();
        if (role != 'owner') {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: EmptyState(
              icon: Icons.lock_outline,
              title: 'غير مسموح',
              subtitle: 'حسابك لاعب. لا يمكنك إنشاء ملعب.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: ModernAppBar(
            title: widget.stadiumId != null ? 'تعديل بيانات الملعب' : 'إضافة ملعب جديد',
          ),
          body: _isLoading
              ? ModernLoading()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF43A047),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.stadium,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ModernCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'اسم الملعب',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _nameController,
                              label: 'أدخل اسم الملعب',
                              icon: Icons.location_city,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'الوصف',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _descriptionController,
                              label: 'أدخل وصف الملعب',
                              icon: Icons.description,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'الموقع / العنوان',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _addressController,
                              label: 'أدخل عنوان الملعب',
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'رقم التواصل',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _phoneController,
                              label: 'أدخل رقم الهاتف',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 12),
                            const Text(
                              'طرق الدفع',
                              style: TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'رقم InstaPay',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _instapayNumberController,
                              label: 'أدخل رقم أو عنوان InstaPay',
                              icon: Icons.account_balance_wallet,
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _pickQrCode,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF404040)),
                                ),
                                child: _instapayQrUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(_instapayQrUrl!,
                                            fit: BoxFit.cover, width: double.infinity),
                                      )
                                    : const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.qr_code_scanner,
                                              color: Color(0xFF43A047), size: 32),
                                          SizedBox(height: 8),
                                          Text('رفع QR كود InstaPay',
                                              style: TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'رقم فودافون كاش',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildInputField(
                              controller: _vodafoneCashNumberController,
                              label: 'أدخل رقم فودافون كاش',
                              icon: Icons.phone_android,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveStadium,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047),
                            disabledBackgroundColor: const Color(0xFF404040),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.stadiumId != null
                                      ? 'تحديث البيانات'
                                      : 'إنشاء الملعب',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF404040)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _instapayNumberController.dispose();
    _vodafoneCashNumberController.dispose();
    super.dispose();
  }
}

