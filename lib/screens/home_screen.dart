import 'package:flutter/material.dart';
import 'package:korateem/screens/fields_screen.dart';
import 'package:korateem/screens/owner_portal_screen.dart';
import 'package:korateem/screens/team_screen.dart';
import 'package:korateem/screens/user_profile_screen.dart';
import 'package:korateem/services/auth_service.dart';
import 'package:korateem/ui/modern_components.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final uid = authService.currentUser?.uid ?? '';

    final pages = <Widget>[
      HomeTabPage(
        uid: uid,
        authService: authService,
        onNavigateTab: (index) => setState(() => _selectedIndex = index),
      ),
      const FieldsScreen(),
      TeamScreen(currentUserId: uid),
      UserProfileScreen(uid: uid),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer),
            label: 'الملاعب',
          ),
          NavigationDestination(icon: Icon(Icons.group), label: 'الفرق'),
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class HomeTabPage extends StatefulWidget {
  final String uid;
  final AuthService authService;
  final ValueChanged<int> onNavigateTab;

  const HomeTabPage({
    super.key,
    required this.uid,
    required this.authService,
    required this.onNavigateTab,
  });

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.authService.currentUser?.displayName;
    final greetingName = (userName == null || userName.trim().isEmpty)
        ? 'مستخدم'
        : userName.trim();

    return Scaffold(
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            title: const Text('كورة تيم'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage:
                        (widget.authService.currentUser?.photoURL?.isNotEmpty ??
                                false)
                            ? NetworkImage(
                              widget.authService.currentUser!.photoURL!,
                            )
                            : null,
                    child:
                        (widget.authService.currentUser?.photoURL?.isNotEmpty ??
                                false)
                            ? null
                            : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/studim.jpeg', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.22),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FadeTransition(
                          opacity: _fade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'أهلاً، $greetingName',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      height: 1.05,
                                    ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'احجز ملعبك، كوّن فريقك، وشارك لحظاتك.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.white70),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الخدمات السريعة',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _QuickActionsGrid(
                      controller: _controller,
                      actions: [
                        _HomeAction(
                          icon: Icons.sports_soccer,
                          title: 'الملاعب',
                          subtitle: 'اكتشف واحجز',
                          onTap: () => widget.onNavigateTab(1),
                        ),
                        _HomeAction(
                          icon: Icons.group,
                          title: 'الفرق',
                          subtitle: 'انضم أو أنشئ',
                          onTap: () => widget.onNavigateTab(2),
                        ),
                        _HomeAction(
                          icon: Icons.feed,
                          title: 'المنشورات',
                          subtitle: 'شارك وتفاعل',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/social-feed',
                            arguments: {'userId': widget.uid},
                          ),
                        ),
                        _HomeAction(
                          icon: Icons.edit,
                          title: 'تعديل الملف',
                          subtitle: 'حدّث بياناتك',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/user-profile-edit',
                            arguments: {'userId': widget.uid},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'الميزات الجديدة',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _ModernFeatureList(controller: _controller, uid: widget.uid),
                    const SizedBox(height: 24),
                    Text(
                      'للأصحاب',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _StaggeredIn(
                      controller: _controller,
                      index: 7,
                      child: ModernCard(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OwnerPortalScreen(ownerId: widget.uid),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.business,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'إدارة ملعبك',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'بوابة صاحب الملعب وإدارة الحجوزات',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final displayName = widget.authService.currentUser?.displayName ?? 'المستخدم';
    final email = widget.authService.currentUser?.email ?? '';
    final photoUrl = widget.authService.currentUser?.photoURL;
    final hasPhoto = (photoUrl != null && photoUrl.isNotEmpty);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/studim.jpeg', fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          backgroundImage:
                              hasPhoto ? NetworkImage(photoUrl) : null,
                          child: hasPhoto
                              ? null
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          displayName,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            textAlign: TextAlign.right,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('حسابي'),
            onTap: () {
              Navigator.pop(context);
              widget.onNavigateTab(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize),
            title: const Text('لوحة التحكم'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/stadium-dashboard',
                arguments: {'ownerId': widget.uid},
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('عن التطبيق'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFCF6679)),
            title: const Text('تسجيل الخروج'),
            onTap: () async {
              Navigator.pop(context);
              await widget.authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _HomeAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _QuickActionsGrid extends StatelessWidget {
  final AnimationController controller;
  final List<_HomeAction> actions;

  const _QuickActionsGrid({required this.controller, required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _StaggeredIn(
          controller: controller,
          index: index,
          child: ModernCard(
            onTap: action.onTap,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    action.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        action.title,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModernFeatureList extends StatelessWidget {
  final AnimationController controller;
  final String uid;

  const _ModernFeatureList({required this.controller, required this.uid});

  @override
  Widget build(BuildContext context) {
    final items = <({
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
    })>[
      (
        icon: Icons.person_add_alt_1,
        title: 'ابحث عن لاعب',
        subtitle: 'جد زملاء لفريقك',
        onTap: () => Navigator.pushNamed(
          context,
          '/search-friends',
          arguments: {'currentUserId': uid},
        ),
      ),
      (
        icon: Icons.star_rate_rounded,
        title: 'قيّم لاعب',
        subtitle: 'شارك رأيك',
        onTap: () => Navigator.pushNamed(
          context,
          '/rate-user',
          arguments: {'userId': '', 'userName': ''},
        ),
      ),
      (
        icon: Icons.stadium,
        title: 'ملعب جديد',
        subtitle: 'أضف ملعبك',
        onTap: () => Navigator.pushNamed(
          context,
          '/stadium-profile',
          arguments: {'ownerId': uid},
        ),
      ),
      (
        icon: Icons.dashboard,
        title: 'لوحة التحكم',
        subtitle: 'إدارة الحجوزات',
        onTap: () => Navigator.pushNamed(
          context,
          '/stadium-dashboard',
          arguments: {'ownerId': uid},
        ),
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _StaggeredIn(
            controller: controller,
            index: 4 + i,
            child: ModernCard(
              onTap: items[i].onTap,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      items[i].icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          items[i].title,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].subtitle,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StaggeredIn extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _StaggeredIn({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.06).clamp(0.0, 0.7);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
