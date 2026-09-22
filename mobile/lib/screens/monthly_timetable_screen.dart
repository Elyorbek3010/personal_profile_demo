import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timetable_model.dart';
import '../widgets/class_item_card.dart';
import '../services/locale_service.dart';

class MonthlyTimetableScreen extends StatefulWidget {
  final List<DayScheduleModel> weeklySchedule;

  const MonthlyTimetableScreen({super.key, required this.weeklySchedule});

  @override
  State<MonthlyTimetableScreen> createState() => _MonthlyTimetableScreenState();
}

class _MonthlyTimetableScreenState extends State<MonthlyTimetableScreen> {
  late DateTime _currentMonth;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  int get _daysInMonth {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  int get _firstWeekday {
    return DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
  }

  List<TimetableClassModel> _getClassesForDate(DateTime date) {
    final now = DateTime.now();
    if (date.year != now.year || date.month != now.month) {
      return [];
    }
    // weekday is 1-7 (Mon-Sun). Our API dayIndex is 0-5 (Mon-Sat).
    final dayIndex = date.weekday - 1;
    try {
      final daySchedule = widget.weeklySchedule.firstWhere((d) => d.dayIndex == dayIndex);
      return daySchedule.classes;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    final daysInMonth = _daysInMonth;
    final firstWeekday = _firstWeekday;
    
    // Calculate weeks for grid
    final totalCells = daysInMonth + firstWeekday - 1;
    final numWeeks = (totalCells / 7).ceil();

    final now = DateTime.now();
    final hasDataForMonth = _currentMonth.year == now.year && _currentMonth.month == now.month;

    final selectedClasses = _getClassesForDate(_selectedDate);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(LocaleService().t('monthly_timetable'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Calendar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Weekday labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    LocaleService().t('day_short_0'),
                    LocaleService().t('day_short_1'),
                    LocaleService().t('day_short_2'),
                    LocaleService().t('day_short_3'),
                    LocaleService().t('day_short_4'),
                    LocaleService().t('day_short_5'),
                    LocaleService().t('day_short_6')
                  ].map((day) {
                    final isWeekend = day == LocaleService().t('day_short_6');
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isWeekend 
                                ? Colors.redAccent 
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: numWeeks * 7,
                  itemBuilder: (context, index) {
                    final dayNumber = index - firstWeekday + 2;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                    final isSelected = _selectedDate.year == date.year && 
                                       _selectedDate.month == date.month && 
                                       _selectedDate.day == date.day;
                    final isToday = DateTime.now().year == date.year && 
                                    DateTime.now().month == date.month && 
                                    DateTime.now().day == date.day;
                    final hasClasses = _getClassesForDate(date).isNotEmpty;
                    
                    final isWeekend = date.weekday == 7;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? primaryColor 
                              : (isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: isToday && !isSelected
                              ? Border.all(color: primaryColor, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                    ? Colors.white 
                                    : (isWeekend ? Colors.redAccent : (isDark ? Colors.white : Colors.black87)),
                              ),
                            ),
                            if (hasClasses)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Schedule for selected day
          Expanded(
            child: !hasDataForMonth
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 48,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocaleService().t('no_classes_this_month'),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          DateFormat('d-MMMM').format(_selectedDate),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: selectedClasses.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy_rounded,
                                      size: 48,
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      LocaleService().t('no_classes_day'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: selectedClasses.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ClassItemCard(
                                      item: selectedClasses[index],
                                    ),
                                  );
                                },
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
