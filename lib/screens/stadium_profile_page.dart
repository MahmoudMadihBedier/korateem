import 'package:flutter/material.dart';
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
        const SnackBar(content: Text('Please fill all required fields')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stadium created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Stadium Profile'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stadium Icon
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.stadium, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Stadium Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Stadium Name',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Address
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Phone
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Phone',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createStadium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Stadium',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
