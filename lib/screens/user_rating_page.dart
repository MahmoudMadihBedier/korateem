import 'package:flutter/material.dart';
import '../ui/modern_components.dart';
import '../../features/user/data/repositories/user_repository.dart';

class UserRatingPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserRatingPage({Key? key, required this.userId, required this.userName})
    : super(key: key);

  @override
  State<UserRatingPage> createState() => _UserRatingPageState();
}

class _UserRatingPageState extends State<UserRatingPage> {
  late UserRepository _userRepository;
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _userRepository.rateUser(widget.userId, _rating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rated ${widget.userName} with $_rating stars!'),
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
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'Rate Player'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF43A047),
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // User Name
              Text(
                widget.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'How would you rate this player?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF808080),
                ),
              ),
              const SizedBox(height: 40),
              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = (index + 1).toDouble();
                        });
                      },
                      child: AnimatedScale(
                        scale: index < _rating ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.star,
                          size: 48,
                          color: index < _rating
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF404040),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Rating Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF404040)),
                ),
                child: Column(
                  children: [
                    Text(
                      _rating == 0 ? 'Select your rating' : 'Rating: $_rating',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_rating > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF404040),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _rating / 5,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF43A047),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rating == 0
                        ? const Color(0xFF404040)
                        : const Color(0xFF43A047),
                    disabledBackgroundColor: const Color(0xFF404040),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Rating',
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
      ),
    );
  }
}
