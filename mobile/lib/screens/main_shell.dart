import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../widgets/avatar_helper.dart';
import '../screens/timetable_screen.dart';
import '../screens/academics_screen.dart';
import '../screens/profile_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  late final List<Widget> _screens = [
    TimetableScreen(onMenuPressed: _openDrawer),
    AcademicsScreen(onMenuPressed: _openDrawer),
    ProfileScreen(
      onBack: () => setState(() => _currentIndex = 0),
      onMenuPressed: _openDrawer,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthService(), LocaleService(), ThemeService()]),
      builder: (context, _) {
        final t = LocaleService().t;

        return Scaffold(
          key: _scaffoldKey,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          drawer: _buildDrawer(context, t),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, String Function(String) t) {
    final user = AuthService().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      backgroundImage: getAvatarImageProvider(user?.avatar),
                      child: getAvatarImageProvider(user?.avatar) == null
                          ? Icon(Icons.person, size: 28, color: isDark ? Colors.white70 : primaryColor)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Talaba',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${user?.group ?? ''} • ${user?.studentId ?? ''}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Navigation Items
            _buildNavItem(
              context,
              index: 0,
              icon: Icons.calendar_today_rounded,
              label: t('nav_timetable'),
              isDark: isDark,
              primaryColor: primaryColor,
            ),
            _buildNavItem(
              context,
              index: 1,
              icon: Icons.insights_rounded,
              label: t('nav_academics'),
              isDark: isDark,
              primaryColor: primaryColor,
            ),
            _buildNavItem(
              context,
              index: 2,
              icon: Icons.person_rounded,
              label: t('nav_profile'),
              isDark: isDark,
              primaryColor: primaryColor,
            ),

            const Spacer(),

            // Theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 20,
                  color: isDark ? Colors.amber : Colors.indigo,
                ),
                title: Text(
                  isDark ? t('theme_dark') : t('theme_light'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                trailing: Switch.adaptive(
                  value: isDark,
                  activeTrackColor: primaryColor,
                  onChanged: (_) => ThemeService().toggleTheme(),
                ),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFEF4444)),
                title: Text(
                  t('logout'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop(); // close drawer
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isSelected = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: isSelected,
        selectedTileColor: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
        leading: Icon(
          icon,
          size: 22,
          color: isSelected ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primaryColor : null,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.of(context).pop(); // close drawer
        },
      ),
    );
  }
}
