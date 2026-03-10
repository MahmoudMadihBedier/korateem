import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/booking_service.dart';
import '../services/auth_service.dart';

class BookingScreen extends StatelessWidget {
  final String fieldId;
  BookingScreen({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('حجز الملعب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختر موعد الحجز:', style: Theme.of(context).textTheme.bodyLarge),
            Wrap(
              spacing: 8,
              children: [
                for (var slot in ['6:00', '7:00', '8:00', '9:00'])
                  ElevatedButton(
                    child: Text(slot),
                    onPressed: () async {
                      await bookingService.bookField(
                        fieldId,
                        authService.userChanges.first.toString(),
                        slot,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم الحجز بنجاح')),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
