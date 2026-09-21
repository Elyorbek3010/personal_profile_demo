import 'package:flutter/material.dart';
import '../models/timetable_model.dart';
import '../services/locale_service.dart';

class NextClassCard extends StatelessWidget {
  final NextClassResponse? response;
  final bool isLoading;

  const NextClassCard({
    super.key,
    required this.response,
    this.isLoading = false,
  });

  String _formatTeacher(String teacher, String Function(String) t) {
    if (teacher.isEmpty) return '';
    final lower = teacher.toLowerCase();
    if (lower.contains('yapon') && lower.contains('qituvchi')) {
      return t('japanese_teacher');
    }
    if (lower.contains('universitet') && lower.contains('qituvchi')) {
      return t('univ_instructor');
    }
    return teacher;
  }

  String _formatRoom(String room, String Function(String) t) {
    if (room.isEmpty) return '';
    final lower = room.toLowerCase();
    if (lower.contains('faollar') || lower.contains('zal')) {
      return t('assembly_hall');
    }
    return "$room${t('room_suffix')}";
  }

  @override
  Widget build(BuildContext context) {
    final t = LocaleService().t;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    if (isLoading) {
      return Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (response == null || !response!.hasNextClass || response!.nextClass == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131D31) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF22324F) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.done_all_rounded, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('no_more_classes'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t('no_more_classes_desc'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final cls = response!.nextClass!;
    final isToday = response!.isToday;
    final localizedDay = t('day_${cls.dayIndex}');
    final formattedTeacher = _formatTeacher(cls.teacher, t);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF172554), // Deep Navy Blue
                  const Color(0xFF0F172A), // Dark Slate
                ]
              : [
                  const Color(0xFFEFF6FF), // Soft Ice Blue
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.35) : const Color(0xFFBFDBFE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF1D4ED8) : const Color(0xFF3B82F6))
                .withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle top-right accent glow
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Status badge & Period capsule
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                              : const Color(0xFF93C5FD),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981), // Pulsing green dot
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isToday ? t('next_class_today') : "${t('next_class')} • $localizedDay",
                            style: TextStyle(
                              color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF1D4ED8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${cls.period}${t('period_suffix')}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Subject Title
                Text(
                  cls.subject,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Info Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPill(
                      context,
                      icon: Icons.access_time_filled_rounded,
                      text: cls.timeSlot,
                      iconColor: const Color(0xFFF59E0B),
                    ),
                    _buildPill(
                      context,
                      icon: Icons.location_on_rounded,
                      text: _formatRoom(cls.room, t),
                      iconColor: const Color(0xFF10B981),
                    ),
                    if (formattedTeacher.isNotEmpty)
                      _buildPill(
                        context,
                        icon: Icons.person_rounded,
                        text: formattedTeacher,
                        iconColor: const Color(0xFF38BDF8),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[200] : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
