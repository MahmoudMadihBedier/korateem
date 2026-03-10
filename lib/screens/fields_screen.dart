import 'package:flutter/material.dart';
import '../services/field_service.dart';

class FieldsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fieldService = FieldService();
    return Scaffold(
      appBar: AppBar(title: Text('الملاعب القريبة')),
      body: StreamBuilder(
        stream: fieldService.getFields(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var fields = snapshot.data!.docs;
          if (fields.isEmpty) {
            return Center(child: Text('لا توجد ملاعب قريبة'));
          }
          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              var data = fields[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(data['images']?[0] ?? ''),
                  ),
                  title: Text(data['name'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('الموقع: ${data['location'] ?? ''}\nالسعر: ${data['price'] ?? ''}'),
                  trailing: ElevatedButton(
                    child: Text('حجز'),
                    onPressed: () {
                      // Navigate to booking screen
                    },
                  ),
                  onTap: () {
                    // Navigate to field profile
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
