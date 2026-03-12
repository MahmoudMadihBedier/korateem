import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/owner_service.dart';

class StadiumDashboardPage extends StatefulWidget {
  final String ownerId;

  const StadiumDashboardPage({Key? key, required this.ownerId})
    : super(key: key);

  @override
  State<StadiumDashboardPage> createState() => _StadiumDashboardPageState();
}

class _StadiumDashboardPageState extends State<StadiumDashboardPage> {
  late OwnerService _ownerService;

  @override
  void initState() {
    super.initState();
    _ownerService = OwnerService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stadium Dashboard'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stadiums List
            StreamBuilder<QuerySnapshot>(
              stream: _ownerService.getOwnerStadiums(widget.ownerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('No stadiums yet'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/stadium_profile',
                              arguments: widget.ownerId,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                          ),
                          child: const Text(
                            'Create Stadium',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final stadiums = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stadiums.length,
                  itemBuilder: (context, index) {
                    final stadium =
                        stadiums[index].data() as Map<String, dynamic>;
                    final stadiumId = stadiums[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          stadium['name'] ?? 'Stadium',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(stadium['address'] ?? 'No address'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  stadium['description'] ?? 'No description',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Contact: ${stadium['phone']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _showBookings(stadiumId),
                                      icon: const Icon(Icons.calendar_today),
                                      label: const Text('Bookings'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _showChat(stadiumId),
                                      icon: const Icon(Icons.chat),
                                      label: const Text('Chat'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookings(String stadiumId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Bookings'),
                backgroundColor: Colors.blue,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _ownerService.getBookings(stadiumId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No bookings yet'));
                    }

                    final bookings = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking =
                            bookings[index].data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(
                            'Booking ${booking['teamName'] ?? 'Team'}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${booking['date'] ?? 'N/A'}'),
                              Text('Time: ${booking['time'] ?? 'N/A'}'),
                              Text('Phone: ${booking['phone'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: const Icon(Icons.phone_in_talk),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChat(String stadiumId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              AppBar(
                title: const Text('Chat with Teams'),
                backgroundColor: Colors.orange,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text('Chat feature coming soon'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
