import 'package:flutter/material.dart';
import '../services/owner_service.dart';

class OwnerPortalScreen extends StatelessWidget {
  final String ownerId;
  const OwnerPortalScreen({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final ownerService = OwnerService();
    return Scaffold(
      appBar: AppBar(title: const Text('بوابة صاحب الملعب')),
      body: StreamBuilder(
        stream: ownerService.getOwnerStadiums(ownerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var fields = snapshot.data!.docs;
          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              var data = fields[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    data['name'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text('السعر: ${data['price'] ?? ''}'),
                  onTap: () {
                    // Navigate to field management
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
