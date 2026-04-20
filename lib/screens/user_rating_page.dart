import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ui/modern_components.dart';
import 'package:provider/provider.dart';
import '../../features/user/data/repositories/user_repository.dart';
import '../../features/stadium/domain/repositories/stadium_repository.dart';
import '../../features/stadium/domain/entities/stadium_entity.dart';
import '../models/team_model.dart';

class UserRatingPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UserRatingPage({super.key, required this.userId, required this.userName});

  @override
  State<UserRatingPage> createState() => _UserRatingPageState();
}

class _UserRatingPageState extends State<UserRatingPage> {
  late UserRepository _userRepository;
  late IStadiumRepository _stadiumRepository;
  double _rating = 0;
  bool _isSubmitting = false;

  String? _selectedTeamId;
  String? _selectedPlayerId;
  String? _selectedPlayerName;
  String? _selectedStadiumId;
  String? _selectedStadiumName;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stadiumRepository = Provider.of<IStadiumRepository>(context, listen: false);
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء اختيار التقييم'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_selectedStadiumId != null) {
        await _stadiumRepository.rateStadium(_selectedStadiumId!, _rating);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تقييم $_selectedStadiumName بـ $_rating نجوم!'),
              backgroundColor: const Color(0xFF43A047),
            ),
          );
        }
      } else {
        final targetId = _selectedPlayerId ?? widget.userId;
        final targetName = _selectedPlayerName ?? widget.userName;
        await _userRepository.rateUser(targetId, _rating);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تقييم $targetName بـ $_rating نجوم!'),
              backgroundColor: const Color(0xFF43A047),
            ),
          );
        }
      }
      if (mounted) Navigator.pop(context);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: ModernAppBar(
          title: 'التقييمات',
          glassy: false,
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'تقييم لاعب'),
                Tab(text: 'تقييم ملعب'),
              ],
              indicatorColor: Color(0xFF43A047),
              labelColor: Color(0xFF43A047),
              unselectedLabelColor: Colors.grey,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPlayerRatingTab(),
                  _buildStadiumRatingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRatingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTeamAndPlayerSelectors(),
          const SizedBox(height: 32),
          if (_selectedPlayerId != null || widget.userId.isNotEmpty) ...[
              // User Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF43A047),
                child: Text(
                  (_selectedPlayerName ?? widget.userName).isNotEmpty
                      ? (_selectedPlayerName ?? widget.userName)[0].toUpperCase()
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
                _selectedPlayerName ?? widget.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'ما هو تقييمك لهذا اللاعب؟',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF808080)),
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
            _buildRatingModule(_selectedPlayerName ?? widget.userName),
          ],
        ],
      ),
    );
  }

  Widget _buildStadiumRatingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          StreamBuilder<List<StadiumEntity>>(
            stream: _stadiumRepository.watchAllStadiums(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final stadiums = snapshot.data!;
              return DropdownButtonFormField<String>(
                initialValue: _selectedStadiumId,
                hint: const Text('اختر الملعب', textAlign: TextAlign.right),
                items: stadiums.map((stadium) => DropdownMenuItem<String>(
                  value: stadium.id,
                  child: Text(stadium.name, textAlign: TextAlign.right),
                )).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _selectedStadiumId = val;
                    _selectedStadiumName = stadiums.firstWhere((s) => s.id == val).name;
                    _selectedPlayerId = null;
                    _selectedTeamId = null;
                  });
                },
                decoration: const InputDecoration(labelText: 'الملعب'),
              );
            },
          ),
          const SizedBox(height: 32),
          if (_selectedStadiumId != null) ...[
            _buildRatingModule(_selectedStadiumName!),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingModule(String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF43A047),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Text(name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text('ما هو تقييمك؟', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF808080))),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => setState(() => _rating = (index + 1).toDouble()),
              child: AnimatedScale(
                scale: index < _rating ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.star,
                  size: 48,
                  color: index < _rating ? const Color(0xFFFF9800) : const Color(0xFF404040),
                ),
              ),
            ),
          )),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            child: _isSubmitting ? const CircularProgressIndicator() : const Text('تأكيد التقييم'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamAndPlayerSelectors() {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('teams').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final teams = snapshot.data!.docs.map((doc) => TeamModel.fromFirestore(doc)).toList();
            return DropdownButtonFormField<String>(
              initialValue: _selectedTeamId,
              hint: const Text('اختر الفريق', textAlign: TextAlign.right),
              items: teams.map((team) => DropdownMenuItem<String>(
                value: team.teamId,
                child: Text(team.name, textAlign: TextAlign.right),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTeamId = val;
                  _selectedPlayerId = null;
                });
              },
              decoration: const InputDecoration(labelText: 'الفريق'),
            );
          },
        ),
        if (_selectedTeamId != null) ...[
          const SizedBox(height: 16),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('teams').doc(_selectedTeamId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final teamData = snapshot.data!.data() as Map<String, dynamic>;
              final memberIds = List<String>.from(teamData['memberIds'] ?? []);

              return FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait(memberIds.map((id) => FirebaseFirestore.instance.collection('users').doc(id).get())),
                builder: (context, playersSnapshot) {
                  if (!playersSnapshot.hasData) return const CircularProgressIndicator();
                  final players = playersSnapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedPlayerId,
                    hint: const Text('اختر اللاعب', textAlign: TextAlign.right),
                    items: players.map((player) {
                      final data = player.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: player.id,
                        child: Text(data['name'] ?? 'لاعب', textAlign: TextAlign.right),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final player = players.firstWhere((p) => p.id == val);
                      final data = player.data() as Map<String, dynamic>;
                      setState(() {
                        _selectedPlayerId = val;
                        _selectedPlayerName = data['name'];
                      });
                    },
                    decoration: const InputDecoration(labelText: 'اللاعب'),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
