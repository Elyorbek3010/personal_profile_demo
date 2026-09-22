import 'package:flutter/material.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';

class ThemeAndLanguageBar extends StatelessWidget {
  final bool showBackground;
  final bool showLanguageSelector;

  const ThemeAndLanguageBar({
    super.key,
    this.showBackground = true,
    this.showLanguageSelector = true,
  });

  static const List<Map<String, String>> languages = [
    {'code': 'uz', 'name': 'O\'zbekcha', 'flag': '🇺🇿'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  ];

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    LocaleService().t('direction') == '専攻' ? '言語の選択' : 'Tilni tanlang / Select Language',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                ...languages.map((lang) {
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
      listenable: Listenable.merge([LocaleService(), ThemeService()]),
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentCode = LocaleService().currentLang;
        final currentLang = languages.firstWhere((l) => l['code'] == currentCode, orElse: () => languages[0]);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLanguageSelector) ...[
              // Language Selector Chip
              InkWell(
                onTap: () => _showLanguagePicker(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentLang['flag']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        currentLang['code']!.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Light / Dark Mode Toggle
            InkWell(
              onTap: () => ThemeService().toggleTheme(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 18,
                  color: isDark ? Colors.amber : Colors.indigo,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
