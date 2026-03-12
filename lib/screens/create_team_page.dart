import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../ui/modern_components.dart';
import '../services/team_service.dart';
import '../features/user/data/models/user_model.dart';
import '../features/user/data/repositories/user_repository.dart';

class CreateTeamPage extends StatefulWidget {
  final String currentUserId;

  const CreateTeamPage({super.key, required this.currentUserId});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage>
    with SingleTickerProviderStateMixin {
  final TeamService _teamService = TeamService();
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _imagePicker = ImagePicker();

  late final TabController _tabController;
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;

  UserModel? _currentUser;
  final Map<String, UserModel> _userCache = {};

  final Set<String> _selectedIds = {};
  String? _captainId;
  File? _imageFile;

  bool _loading = true;
  bool _saving = false;
  bool _pickingImage = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      final next = _searchController.text;
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });

    if (widget.currentUserId.trim().isNotEmpty) {
      _selectedIds.add(widget.currentUserId);
      _captainId = widget.currentUserId;
    }

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _userRepository.getUser(widget.currentUserId);
      _userCache[user.id] = user;
      setState(() {
        _currentUser = user;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
    }
  }

  Future<void> _pickTeamImage() async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;
      if (!mounted) return;
      setState(() => _imageFile = File(image.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح معرض الصور. حاول مرة أخرى.'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _pickingImage = false);
      }
    }
  }

  void _toggleMember(UserModel user) {
    final id = user.id;
    if (id.trim().isEmpty) return;

    setState(() {
      _userCache[id] = user;
      if (_selectedIds.contains(id)) {
        // Don't allow removing the current user (keeps team anchored).
        if (id == widget.currentUserId) return;
        _selectedIds.remove(id);
        if (_captainId == id) {
          _captainId = widget.currentUserId;
        }
      } else {
        if (_selectedIds.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الحد الأقصى ٥ لاعبين في الفريق'),
              backgroundColor: Color(0xFFCF6679),
            ),
          );
          return;
        }
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _createTeam() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب اسم الفريق'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }
    if (_selectedIds.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لازم تختار ٥ لاعبين بالضبط'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }
    final captainId = _captainId;
    if (captainId == null || captainId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختار كابتن للفريق'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختار صورة للفريق'),
          backgroundColor: Color(0xFFCF6679),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final captainName =
          _userCache[captainId]?.name ?? _currentUser?.name ?? 'كابتن';

      await _teamService.createTeam(
        name: name,
        captainId: captainId,
        captainName: captainName,
        memberIds: _selectedIds.toList(),
        imageFile: _imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الفريق بنجاح'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final msg = '$e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg.contains('cloud_firestore/permission-denied') ||
                      msg.contains('PERMISSION_DENIED')
                  ? 'لا يمكن إنشاء الفريق بسبب صلاحيات Firebase. انشر قواعد Firestore من ملف `FIREBASE_DEPLOY_RULES.md`.'
                  : msg.contains('firebase_storage') ||
                        msg.contains('StorageException') ||
                        msg.contains('object-not-found') ||
                        msg.contains('404') ||
                        msg.toLowerCase().contains('not found')
                  ? 'تعذر رفع صورة الفريق. غالباً Firebase Storage غير مفعّل أو اسم الـ bucket غير صحيح. افتح Firebase Console > Storage > Get started ثم انشر قواعد Storage من `FIREBASE_DEPLOY_RULES.md` وحاول مرة أخرى.'
                  : 'خطأ: $e',
            ),
            backgroundColor: const Color(0xFFCF6679),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: ModernAppBar(title: 'إنشاء فريق'),
        body: ModernLoading(),
      );
    }

    if (widget.currentUserId.trim().isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: ModernAppBar(title: 'إنشاء فريق'),
        body: const EmptyState(
          icon: Icons.lock_outline,
          title: 'سجل الدخول أولاً',
          subtitle: 'لازم تسجل الدخول علشان تنشئ فريق',
        ),
      );
    }

    final selectedCount = _selectedIds.length;
    final canCreate = !_saving && selectedCount == 5;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: ModernAppBar(title: 'إنشاء فريق'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بيانات الفريق',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'اسم الفريق',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _saving ? null : _pickTeamImage,
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF43A047),
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'اللاعبين المختارين: $selectedCount/5',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _captainId,
                    decoration: const InputDecoration(
                      labelText: 'كابتن الفريق',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                    items: _selectedIds.map((id) {
                      final name = _userCache[id]?.name;
                      final label = (name != null && name.trim().isNotEmpty)
                          ? name
                          : id.substring(0, id.length >= 8 ? 8 : id.length);
                      return DropdownMenuItem(value: id, child: Text(label));
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _captainId = value),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFF1E1E1E),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF43A047),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF808080),
              tabs: const [
                Tab(text: 'أصدقاؤك'),
                Tab(text: 'كل اللاعبين'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FriendsPicker(
                  currentUser: _currentUser,
                  userRepository: _userRepository,
                  selectedIds: _selectedIds,
                  onToggle: _toggleMember,
                  onCache: (u) => _userCache[u.id] = u,
                ),
                _AllUsersPicker(
                  currentUserId: widget.currentUserId,
                  userRepository: _userRepository,
                  selectedIds: _selectedIds,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  onToggle: _toggleMember,
                  onCache: (u) => _userCache[u.id] = u,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: canCreate ? _createTeam : null,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('إنشاء الفريق'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsPicker extends StatelessWidget {
  final UserModel? currentUser;
  final UserRepository userRepository;
  final Set<String> selectedIds;
  final void Function(UserModel user) onToggle;
  final void Function(UserModel user) onCache;

  const _FriendsPicker({
    required this.currentUser,
    required this.userRepository,
    required this.selectedIds,
    required this.onToggle,
    required this.onCache,
  });

  @override
  Widget build(BuildContext context) {
    final friendIds = currentUser?.friends ?? const <String>[];
    if (friendIds.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        title: 'مفيش أصدقاء لسه',
        subtitle: 'ابدأ بإضافة أصدقاء علشان يظهروا هنا',
      );
    }

    return StreamBuilder<List<UserModel>>(
      stream: userRepository.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return ModernLoading();
        final friends = snapshot.data!
            .where((u) => friendIds.contains(u.id))
            .toList();
        if (friends.isEmpty) {
          return const EmptyState(
            icon: Icons.group_off,
            title: 'لا توجد نتائج',
            subtitle: 'أصدقاؤك غير متاحين الآن',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final user = friends[index];
            onCache(user);
            final selected = selectedIds.contains(user.id);
            final disabled = !selected && selectedIds.length >= 5;
            return _UserPickTile(
              user: user,
              selected: selected,
              disabled: disabled,
              onTap: () => onToggle(user),
            );
          },
        );
      },
    );
  }
}

class _AllUsersPicker extends StatelessWidget {
  final String currentUserId;
  final UserRepository userRepository;
  final Set<String> selectedIds;
  final TextEditingController searchController;
  final String searchQuery;
  final void Function(UserModel user) onToggle;
  final void Function(UserModel user) onCache;

  const _AllUsersPicker({
    required this.currentUserId,
    required this.userRepository,
    required this.selectedIds,
    required this.searchController,
    required this.searchQuery,
    required this.onToggle,
    required this.onCache,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'ابحث عن لاعب بالاسم أو الإيميل أو الموبايل...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: searchQuery.trim().isEmpty
                ? userRepository.getAllUsers()
                : userRepository.searchUsers(searchQuery),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return ModernLoading();
              final users = snapshot.data!
                  .where((u) => u.id != currentUserId)
                  .toList();

              if (users.isEmpty) {
                return const EmptyState(
                  icon: Icons.person_search,
                  title: 'لا توجد نتائج',
                  subtitle: 'جرّب كلمة بحث مختلفة',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  onCache(user);
                  final selected = selectedIds.contains(user.id);
                  final disabled = !selected && selectedIds.length >= 5;
                  return _UserPickTile(
                    user: user,
                    selected: selected,
                    disabled: disabled,
                    onTap: () => onToggle(user),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserPickTile extends StatelessWidget {
  final UserModel user;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _UserPickTile({
    required this.user,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        child: ListTile(
          enabled: !disabled,
          onTap: disabled ? null : onTap,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF43A047),
            backgroundImage:
                user.profileImage != null && user.profileImage!.isNotEmpty
                ? NetworkImage(user.profileImage!)
                : null,
            child: (user.profileImage == null || user.profileImage!.isEmpty)
                ? Text(
                    user.name.isNotEmpty ? user.name[0] : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(user.name.isNotEmpty ? user.name : 'مستخدم'),
          subtitle: Text(
            user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Checkbox(
            value: selected,
            onChanged: disabled ? null : (_) => onTap(),
            activeColor: const Color(0xFF43A047),
          ),
        ),
      ),
    );
  }
}
