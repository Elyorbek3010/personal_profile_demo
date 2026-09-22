import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/avatar_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onMenuPressed;

  const ProfileScreen({
    super.key,
    this.onBack,
    this.onMenuPressed,
  });

  static const List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=256',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=256',
  ];

  void _showAvatarPicker(BuildContext context) {
    final t = LocaleService().t;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final user = AuthService().currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t('change_avatar'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Option 1: Choose from Gallery
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library_rounded, color: primaryColor, size: 22),
                  ),
                  title: Text(
                    t('choose_from_gallery'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                        await AuthService().updateAvatar(base64Image);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t('avatar_updated')),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Gallery pick error: $e');
                    }
                  },
                ),

                const SizedBox(height: 16),
                // Section: Preset Avatars
                Text(
                  t('preset_avatars'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final avatarUrl = _presetAvatars[index];
                      final isSelected = user?.avatar == avatarUrl;

                      return GestureDetector(
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          await AuthService().updateAvatar(avatarUrl);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(t('avatar_updated')),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(avatarUrl),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Option 3: Remove Avatar (Optional reset)
                if (user?.avatar.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                    ),
                    title: Text(
                      t('remove_avatar'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await AuthService().updateAvatar('');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('avatar_updated')),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  void _showLogoutDialog(BuildContext context) {
    final t = LocaleService().t;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(
          t('logout_confirm_title'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          t('logout_confirm_desc'),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(t('logout')),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final currentCode = LocaleService().currentLang;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Tilni tanlang / Select Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                ...ThemeAndLanguageBar.languages.map((lang) {
                  final isSelected = lang['code'] == currentCode;
                  return ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected
                        ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04))
                        : null,
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () {
                      LocaleService().setLanguage(lang['code']!);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthService(), LocaleService(), ThemeService()]),
      builder: (context, _) {
        final t = LocaleService().t;
        final user = AuthService().currentUser;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = Theme.of(context).primaryColor;
        final currentLang = ThemeAndLanguageBar.languages.firstWhere(
          (l) => l['code'] == LocaleService().currentLang,
          orElse: () => ThemeAndLanguageBar.languages[0],
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t('profile_title'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Navigator.canPop(context) || onBack != null
                    ? Icons.arrow_back_rounded
                    : Icons.menu_rounded,
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else if (onBack != null) {
                  onBack!();
                } else if (onMenuPressed != null) {
                  onMenuPressed!();
                } else {
                  context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer();
                }
              },
            ),
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Profile Card Header (Editable Avatar)
            Center(
              child: GestureDetector(
                onTap: () => _showAvatarPicker(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.35),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        backgroundImage: getAvatarImageProvider(user?.avatar),
                        child: getAvatarImageProvider(user?.avatar) == null
                            ? Icon(Icons.person, size: 44, color: primaryColor)
                            : null,
                      ),
                    ),
                    // Edit Camera Badge at bottom right
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                    // Verified Badge at top right
                    if (user?.isVerified == true)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? t('role_student'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Academic Information Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    context,
                    Icons.badge_outlined,
                    t('student_id'),
                    user?.studentId.isNotEmpty == true ? user!.studentId : "-",
                    const Color(0xFF0284C7),
                  ),
                  Divider(color: Theme.of(context).colorScheme.outline, height: 1),
                  _buildInfoTile(
                    context,
                    Icons.groups_outlined,
                    t('group'),
                    user?.group ?? '-',
                    primaryColor,
                  ),
                  Divider(color: Theme.of(context).colorScheme.outline, height: 1),
                  _buildInfoTile(
                    context,
                    Icons.school_outlined,
                    t('course'),
                    t('course_n').replaceAll('{n}', user?.course ?? '1'),
                    const Color(0xFF059669),
                  ),
                  Divider(color: Theme.of(context).colorScheme.outline, height: 1),
                  _buildInfoTile(
                    context,
                    Icons.terminal_rounded,
                    t('direction'),
                    (user?.direction == 'IT') ? t('dir_it') : (user?.direction ?? 'IT'),
                    const Color(0xFFD97706),
                  ),
                  Divider(color: Theme.of(context).colorScheme.outline, height: 1),
                  _buildInfoTile(
                    context,
                    Icons.account_balance_outlined,
                    t('partner_uni'),
                    user?.partnerUniversity ?? 'JDU',
                    const Color(0xFF7C3AED),
                  ),
                  Divider(color: Theme.of(context).colorScheme.outline, height: 1),
                  _buildInfoTile(
                    context,
                    Icons.translate_rounded,
                    t('japanese'),
                    user?.japaneseExempt == true ? t('japanese_exempt') : t('japanese_required'),
                    user?.japaneseExempt == true ? const Color(0xFF059669) : const Color(0xFFE11D48),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Card (Theme & Language)
            Material(
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                children: [
                  // Theme Toggle Tile
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.amber : Colors.indigo).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 20,
                        color: isDark ? Colors.amber : Colors.indigo,
                      ),
                    ),
                    title: Text(
                      isDark ? t('theme_dark') : t('theme_light'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeTrackColor: primaryColor,
                      onChanged: (_) => ThemeService().toggleTheme(),
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.outline, height: 1),
                  // Language Selection Tile
                  ListTile(
                    onTap: () => _showLanguagePicker(context),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(currentLang['flag']!, style: const TextStyle(fontSize: 16)),
                    ),
                    title: Text(
                      currentLang['name']!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentLang['code']!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(t('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
