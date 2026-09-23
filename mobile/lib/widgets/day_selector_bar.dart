import 'package:flutter/material.dart';
import '../models/timetable_model.dart';
import '../services/locale_service.dart';

class DaySelectorBar extends StatelessWidget {
  final int selectedDayIndex;
  final List<DayScheduleModel> schedule;
  final ValueChanged<int> onDaySelected;

  const DaySelectorBar({
    super.key,
    required this.selectedDayIndex,
    required this.schedule,
    required this.onDaySelected,
  });

  static const List<int> weekdays = [0, 1, 2, 3, 4, 5];

  int _getClassCount(int dayIndex) {
    final day = schedule.firstWhere(
      (d) => d.dayIndex == dayIndex,
      orElse: () => DayScheduleModel(
        dayIndex: dayIndex,
        dayName: '',
        classesCount: 0,
        classes: [],
      ),
    );
    
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;
    final targetDate = now.add(Duration(days: dayIndex - currentDayIndex));
    final dateString = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    return day.classes.where((c) {
      if (c.specificDate != null && c.specificDate!.isNotEmpty) {
        return c.specificDate == dateString;
      }
      return true;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final t = LocaleService().t;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 74,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: weekdays.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final int dayIndex = weekdays[idx];
          final isSelected = dayIndex == selectedDayIndex;
          final count = _getClassCount(dayIndex);
          final dayShort = t('day_short_$dayIndex');

          return GestureDetector(
            onTap: () => onDaySelected(dayIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6), // Blue 500
                          Color(0xFF1D4ED8), // Blue 700
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? const Color(0xFF131D31) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF60A5FA)
                      : (isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.45 : 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayShort,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[200] : const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : (count > 0
                              ? const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.1)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      count > 0 ? "$count ${t('classes_suffix')}" : "—",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (count > 0
                                ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                                : (isDark ? Colors.grey[600] : Colors.grey[400])),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
