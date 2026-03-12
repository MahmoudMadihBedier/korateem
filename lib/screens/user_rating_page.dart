import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    try {
      await _userRepository.rateUser(widget.userId, _rating);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate User'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User name
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = (index + 1).toDouble();
                    });
                  },
                  child: Icon(
                    Icons.star,
                    size: 48,
                    color: index < _rating ? Colors.amber : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Rating value
            Text(
              _rating == 0
                  ? 'Select your rating'
                  : 'Rating: ${_rating.toStringAsFixed(1)} ⭐',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Submit Rating',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
