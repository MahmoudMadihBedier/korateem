import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../ui/modern_components.dart';
import '../../features/user/data/repositories/user_repository.dart';
import '../../features/user/data/models/user_model.dart';
import '../services/booking_service.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late UserRepository _userRepository;
  late BookingService _bookingService;
  UserModel? _user;
  bool _isLoading = false;
  late ImagePicker _imagePicker;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
    _bookingService = BookingService();
    _imagePicker = ImagePicker();
    _loadUserProfile();
  }

  Future<void> _handlePaymentUpload(String bookingId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isLoading = true);

        final File imageFile = File(image.path);
        final String fileName =
            'payment_${bookingId}_${DateTime.now().millisecondsSinceEpoch}';
        final Reference ref = FirebaseStorage.instance.ref().child(
          'payments/$fileName',
        );

        await ref.putFile(imageFile);
        final String downloadUrl = await ref.getDownloadURL();

        await _bookingService.uploadPaymentScreenshot(
          bookingId: bookingId,
          screenshotUrl: downloadUrl,
        );

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع إثبات الدفع بنجاح'),
              backgroundColor: Color(0xFF43A047),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الصورة: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
    }
  }

  Future<void> _showPaymentDetails(Map<String, dynamic> booking) async {
    final stadiumId = booking['stadiumId'];
    final stadiumDoc = await FirebaseFirestore.instance.collection('stadiums').doc(stadiumId).get();
    final stadiumData = stadiumDoc.data();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'بيانات الدفع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              if (stadiumData?['instapayNumber'] != null) ...[
                Text('InstaPay: ${stadiumData!['instapayNumber']}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
              ],
              if (stadiumData?['vodafoneCashNumber'] != null) ...[
                Text('Vodafone Cash: ${stadiumData!['vodafoneCashNumber']}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
              ],
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePaymentUpload(booking['id']);
                  },
                  child: const Text('رفع إثبات الدفع'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userRepository.getUser(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isLoading = true);

        final File imageFile = File(image.path);
        final String fileName =
            'profile_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}';
        final Reference ref = FirebaseStorage.instance.ref().child(
          'profiles/$fileName',
        );

        await ref.putFile(imageFile);
        final String downloadUrl = await ref.getDownloadURL();

        final updatedUser = UserModel(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          phone: _user!.phone,
          profileImage: downloadUrl,
          friends: _user!.friends,
          rating: _user!.rating,
        );

        await _userRepository.updateUserProfile(updatedUser);

        setState(() {
          _user = updatedUser;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully'),
              backgroundColor: Color(0xFF43A047),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: ModernLoading(),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: EmptyState(
          icon: Icons.person_outline,
          title: 'Profile Not Found',
          subtitle: 'Unable to load user profile',
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'My Profile'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Rating Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ModernCard(
                child: Column(
                  children: [
                    Text(
                      _user!.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF43A047),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _user!.rating.toInt()
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFFFA500),
                          size: 24,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: widget.userId)
                    .snapshots(),
                builder: (context, bookingSnapshot) {
                  final bookingCount = bookingSnapshot.hasData ? bookingSnapshot.data!.docs.length : 0;
                  final friendCount = _user!.friends.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('$bookingCount', 'حجوزات'),
                      _buildStatCard('$friendCount', 'أصدقاء'),
                      _buildStatCard(_user!.rating.toStringAsFixed(1), 'تقييم'),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Achievements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المهارات والإنجازات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ModernCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAchievementIcon(
                          Icons.sentiment_satisfied,
                          'روح رياضة',
                          const Color(0xFFFFA500),
                        ),
                        _buildAchievementIcon(
                          Icons.flash_on,
                          'الالعب السريع',
                          const Color(0xFF43A047),
                        ),
                        _buildAchievementIcon(
                          Icons.lock_outline,
                          'جدار حديدي',
                          const Color(0xFF808080),
                        ),
                        _buildAchievementIcon(
                          Icons.public,
                          'هدافة الموسم',
                          const Color(0xFF43A047),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Bookings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجوزات حديثة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBookingsList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Ratings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ التقييمات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF43A047),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRatingsHistory(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF43A047), width: 3),
                ),
                child:
                    _user!.profileImage != null &&
                        _user!.profileImage!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(_user!.profileImage!),
                      )
                    : CircleAvatar(
                        backgroundColor: const Color(0xFF43A047),
                        child: Text(
                          _user!.name.isNotEmpty ? _user!.name[0] : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: _uploadProfileImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF43A047),
                    border: Border.all(
                      color: const Color(0xFF121212),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _user!.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.phone,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF808080)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return ModernCard(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF43A047),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF808080)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF808080)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('date', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ModernLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ModernCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'لا توجد حجوزات حديثة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF808080),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final booking = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModernCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF43A047),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.stadium,
                        color: Color(0xFF43A047),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['stadium'] ?? 'ملعب',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            'فرع الرياض • ${booking['date']}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF808080)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${booking['time']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF43A047),
                          ),
                        ),
                        if (booking['status'] == 'waiting_payment' && booking['paymentStatus'] == null)
                          TextButton(
                            onPressed: () => _showPaymentDetails({...booking, 'id': doc.id}),
                            child: const Text('دفع', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRatingsHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('ratedUserId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ModernLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ModernCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'لا توجد تقييمات حديثة',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF808080),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final rating = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rating['raterName'] ?? 'مستخدم',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (rating['rating'] ?? 0).toInt()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFFA500),
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    if (rating['comment'] != null &&
                        rating['comment'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          rating['comment'],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFFB0B0B0)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
