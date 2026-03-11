import 'package:flutter/material.dart';
import '../services/team_service.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    return Scaffold(
      appBar: AppBar(title: Text('الفرق')),
      body: StreamBuilder(
        stream: teamService.getTeams(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var teams = snapshot.data!.docs;
          if (teams.isEmpty) {
            return Center(child: Text('لا توجد فرق'));
          }
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              var data = teams[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    data['name'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    'عدد الأعضاء: ${(data['members'] as List).length}',
                  ),
                  onTap: () {
                    // Navigate to team details
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
