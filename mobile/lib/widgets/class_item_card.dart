import 'package:flutter/material.dart';
import '../models/timetable_model.dart';
import '../services/locale_service.dart';

class ClassItemCard extends StatelessWidget {
  final TimetableClassModel item;

  const ClassItemCard({super.key, required this.item});

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

    // Accent color based on category/partner
    Color accentColor = const Color(0xFF3B82F6); // Royal Blue
    if (item.isJapanese) {
      accentColor = const Color(0xFFF43F5E); // Bright Rose
    } else if (item.targetPartner == 'SANNO') {
      accentColor = const Color(0xFFA855F7); // Bright Purple
    } else if (item.targetPartner == 'TOU') {
      accentColor = const Color(0xFF0EA5E9); // Bright Sky Blue
    }

    final formattedTeacher = _formatTeacher(item.teacher, t);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D31) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E2D4A)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Period Badge Box with left glow
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: isDark ? 0.3 : 0.15),
                    accentColor.withValues(alpha: isDark ? 0.15 : 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.6 : 0.35),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  "${item.period}",
                  style: TextStyle(
                    color: isDark ? Colors.white : accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Class Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Meta Row: Time & Room & Partner
                  Row(
                    children: [
                      // Time pill
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: const Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.timeSlot,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      // Room pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatRoom(item.room, t),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Partner Tag (TOU, SANNO, etc.)
                      if (item.targetPartner != 'ALL')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: accentColor.withValues(alpha: isDark ? 0.45 : 0.25),
                            ),
                          ),
                          child: Text(
                            item.targetPartner,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Subject Name
                  Text(
                    item.subject,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),

                  // Teacher Name (if present)
                  if (formattedTeacher.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formattedTeacher,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
