import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final String fieldId;
  const BookingScreen({super.key, required this.fieldId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final bookingService = BookingService();
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  int _numberOfPlayers = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حجز الملعب'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date selector
              _buildSectionTitle('اختر التاريخ'),
              SizedBox(height: 12),
              _buildDatePicker(),
              SizedBox(height: 24),

              // Time slots
              _buildSectionTitle('اختر الوقت'),
              SizedBox(height: 12),
              _buildTimeSlots(),
              SizedBox(height: 24),

              // Players count
              _buildSectionTitle('عدد اللاعبين'),
              SizedBox(height: 12),
              _buildPlayersCounter(),
              SizedBox(height: 24),

              // Price summary
              _buildPriceSummary(),
              SizedBox(height: 24),

              // Booking button
              _buildBookingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _pickDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التاريخ المختار',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('EEEE، d MMMM y', 'ar').format(_selectedDate),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: Color(0xFF1E88E5)),
          ],
        ),
      ),
    );
  }

  void _pickDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
    ).then((date) {
      if (date != null) {
        setState(() => _selectedDate = date);
      }
    });
  }

  Widget _buildTimeSlots() {
    final timeSlots = [
      '06:00',
      '07:00',
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF1E88E5) : Colors.grey[100],
              border: Border.all(
                color: isSelected ? Color(0xFF1E88E5) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                slot,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayersCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('عدد اللاعبين:', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Color(0xFF1E88E5)),
                onPressed: _numberOfPlayers > 1
                    ? () => setState(() => _numberOfPlayers--)
                    : null,
              ),
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    _numberOfPlayers.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFF1E88E5)),
                onPressed: () => setState(() => _numberOfPlayers++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final pricePerHour = 100.0;
    final pricePerPlayer = 25.0;
    final totalPrice = (pricePerHour + (pricePerPlayer * _numberOfPlayers));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('سعر الملعب'), Text('$pricePerHour ج.م')],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سعر اللاعب ($_numberOfPlayers)'),
              Text('${pricePerPlayer * _numberOfPlayers} ج.م'),
            ],
          ),
          Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المجموع', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${totalPrice.toStringAsFixed(2)} ج.م',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    final isValid = _selectedSlot != null;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isValid ? _confirmBooking : null,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'تأكيد الحجز',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('الرجاء اختيار وقت الحجز')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حجز الملعب بنجاح!'),
        backgroundColor: Color(0xFF43A047),
      ),
    );
    Future.delayed(Duration(seconds: 2), () => Navigator.pop(context));
  }
}
