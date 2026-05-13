import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';
import '../../home/screens/home_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../settings/screens/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    _scaffoldKey.currentState?.closeDrawer();
    Future.delayed(const Duration(milliseconds: 300), () {
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 58,
                height: 58,
                color: Colors.transparent,
                child: Image.asset('assets/images/vv.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ],
        title: Text(
          'V E I N',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 8),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: VeinTheme.cream.withValues(alpha: 0.12))),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Workouts'),
                Tab(text: 'Progress'),
                Tab(text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
      drawer: _Drawer(session: widget.session, onNavigate: _navigateToTab),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(session: widget.session, onSwitchTab: _navigateToTab).animate().fadeIn(duration: 140.ms),
          ProgressScreen(session: widget.session).animate().fadeIn(duration: 140.ms),
          SettingsScreen(session: widget.session).animate().fadeIn(duration: 140.ms),
        ],
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({required this.session, required this.onNavigate});

  final AppSession session;
  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Drawer(
      backgroundColor: VeinTheme.maroonBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: VeinTheme.cream.withValues(alpha: 0.16),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vein', style: t.titleLarge?.copyWith(letterSpacing: 2.0)),
                        const SizedBox(height: 4),
                        Text(
                          session.user?.displayName ?? 'Demo User',
                          style: t.bodyMedium?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.78)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(icon: Icons.fitness_center_rounded, label: 'Workouts', onTap: () => onNavigate(0)),
            _DrawerItem(icon: Icons.trending_up_rounded, label: 'Progress', onTap: () => onNavigate(1)),
            _DrawerItem(icon: Icons.person_rounded, label: 'Profile', onTap: () => onNavigate(2)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Text(
                'Philippians 4:13 - I can do all things through Christ which strengtheneth me.',
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.72), letterSpacing: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
