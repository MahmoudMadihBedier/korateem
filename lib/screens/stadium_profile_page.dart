import 'package:flutter/material.dart';
import '../ui/modern_components.dart';
import '../../services/owner_service.dart';

class StadiumProfilePage extends StatefulWidget {
  final String ownerId;

  const StadiumProfilePage({Key? key, required this.ownerId}) : super(key: key);

  @override
  State<StadiumProfilePage> createState() => _StadiumProfilePageState();
}

class _StadiumProfilePageState extends State<StadiumProfilePage> {
  late OwnerService _ownerService;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ownerService = OwnerService();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  Future<void> _createStadium() async {
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
      await _ownerService.addStadiumProfile(widget.ownerId, {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'photos': <String>[],
        'busyTimes': <Map<String, dynamic>>[],
        'freeTimes': <Map<String, dynamic>>[],
        'rating': 0.0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stadium created successfully'),
            backgroundColor: Color(0xFF43A047),
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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'Create Stadium'),
      body: _isLoading
          ? ModernLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stadium Icon
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
                  // Form Fields
                  ModernCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stadium Name
                        Text(
                          'Stadium Name',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameController,
                          label: 'Enter stadium name',
                          icon: Icons.location_city,
                        ),
                        const SizedBox(height: 20),
                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _descriptionController,
                          label: 'Enter stadium description',
                          icon: Icons.description,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        // Address
                        Text(
                          'Location/Address',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _addressController,
                          label: 'Enter stadium address',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 20),
                        // Phone
                        Text(
                          'Contact Phone',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Enter phone number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createStadium,
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
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Stadium',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
