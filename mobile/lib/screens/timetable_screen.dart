import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timetable_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../widgets/avatar_helper.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/class_item_card.dart';
import '../widgets/day_selector_bar.dart';
import '../widgets/next_class_card.dart';
import 'profile_screen.dart';
import 'monthly_timetable_screen.dart';

class TimetableScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const TimetableScreen({super.key, this.onMenuPressed});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final ApiService _api = ApiService();
  StreamSubscription? _fcmSubscription;
  List<DayScheduleModel> _schedule = [];
  NextClassResponse? _nextClass;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default selected day to current weekday (0=Mon, 6=Sun)
    final today = DateTime.now().weekday - 1;
    _selectedDayIndex = (today >= 0 && today <= 5) ? today : 0;
    _loadData();
    
    _fcmSubscription = FCMService().onScheduleUpdate.listen((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _api.getMySchedule(),
        _api.getNextClass(),
      ]);

      if (mounted) {
        setState(() {
          _schedule = results[0] as List<DayScheduleModel>;
          _nextClass = results[1] as NextClassResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  DayScheduleModel? get _currentDaySchedule {
    try {
      return _schedule.firstWhere((d) => d.dayIndex == _selectedDayIndex);
    } catch (_) {
      return null;
    }
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

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                if (widget.onMenuPressed != null) {
                  widget.onMenuPressed!();
                } else {
                  context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer();
                }
              },
            ),
            title: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar with glowing gradient border
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        backgroundImage: getAvatarImageProvider(user?.avatar),
                        child: getAvatarImageProvider(user?.avatar) == null
                            ? Icon(Icons.person, size: 20, color: primaryColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  user?.name ?? 'Talaba',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (user?.isVerified == true) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 14, color: Color(0xFF38BDF8)),
                              ],
                            ],
                          ),
                          Text(
                            "${user?.group ?? ''} • ${user?.studentId ?? ''}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: const [
              ThemeAndLanguageBar(showLanguageSelector: false),
              SizedBox(width: 12),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFF2563EB),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: primaryColor,
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorView(t)
                    : CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Next Class Card Hero
                          SliverToBoxAdapter(
                            child: NextClassCard(response: _nextClass),
                          ),

                          // Academic Context Strip (Monthly Schedule Button)
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark 
                                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                                      : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF2563EB).withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MonthlyTimetableScreen(
                                          weeklySchedule: _schedule,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF3B82F6).withOpacity(0.2) : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              if (!isDark)
                                                BoxShadow(
                                                  color: const Color(0xFF2563EB).withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.calendar_month_rounded,
                                            size: 24,
                                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t('monthly_timetable'),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                t('view_monthly_schedule'),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 4),
                          ),

                          // Day Selector Bar
                          SliverToBoxAdapter(
                            child: DaySelectorBar(
                              selectedDayIndex: _selectedDayIndex,
                              schedule: _schedule,
                              onDaySelected: (idx) {
                                setState(() {
                                  _selectedDayIndex = idx;
                                });
                              },
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 4),
                          ),

                          // Classes List
                          _buildClassesList(t),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 36),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _buildClassesList(String Function(String) t) {
    final dayData = _currentDaySchedule;
    final allClasses = dayData?.classes ?? [];
    
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;
    final targetDate = now.add(Duration(days: _selectedDayIndex - currentDayIndex));
    final dateString = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    final classes = allClasses.where((c) {
      if (c.specificDate != null && c.specificDate!.isNotEmpty) {
        return c.specificDate == dateString;
      }
      return true;
    }).toList();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (classes.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.2 : 0.1),
                      const Color(0xFF2563EB).withValues(alpha: isDark ? 0.1 : 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 36,
                  color: Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                t('no_classes_day'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t('no_classes_day_desc'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = classes[index];
          return ClassItemCard(item: item);
        },
        childCount: classes.length,
      ),
    );
  }

  Widget _buildErrorView(String Function(String) t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 14),
            Text(
              _errorMessage ?? t('error_occurred'),
              style: const TextStyle(fontSize: 14, color: Color(0xFFEF4444)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(t('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
