import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/academic_model.dart';
import '../services/api_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';

class AcademicsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const AcademicsScreen({super.key, this.onMenuPressed});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  bool _needsSetup = false;
  String? _errorMessage;
  AcademicReport? _report;
  late TabController _tabController;
  final TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _api.getAcademicData();
      if (mounted) {
        if (data['has_data'] == true) {
          setState(() {
            _report = AcademicReport.fromJson(data['data']);
            _needsSetup = false;
            _isLoading = false;
          });
        } else {
          setState(() {
            _needsSetup = true;
            _isLoading = false;
          });
        }
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

  Future<void> _submitLink() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await _api.setDataLink(link);
      if (result['success'] == true) {
        _linkController.clear();
        await _loadData();
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result['error']?.toString();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), ThemeService()]),
      builder: (context, _) {
        final t = LocaleService().t;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t('academics_title'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
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
          ),
          body: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t('loading_data'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _needsSetup
                  ? _buildSetupView(context, t, isDark)
                  : _errorMessage != null
                      ? _buildErrorView(t)
                      : _buildDataView(context, t, isDark),
        );
      },
    );
  }

  // ── Setup View: Enter data.jdu.uz link ──
  Widget _buildSetupView(BuildContext context, String Function(String) t, bool isDark) {
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  primaryColor.withValues(alpha: isDark ? 0.05 : 0.02),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.link_rounded, size: 48, color: primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            t('enter_link_title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t('enter_link_desc'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Link input field
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: TextField(
              controller: _linkController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: t('enter_link_hint'),
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(Icons.content_paste_rounded, color: primaryColor, size: 20),
                  tooltip: t('paste_btn'),
                  onPressed: () async {
                    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                    if (clipboardData?.text != null) {
                      _linkController.text = clipboardData!.text!;
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Paste button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                if (clipboardData?.text != null) {
                  _linkController.text = clipboardData!.text!;
                }
              },
              icon: const Icon(Icons.content_paste_go_rounded, size: 18),
              label: Text(t('paste_btn')),
            ),
          ),
          const SizedBox(height: 12),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _submitLink,
              child: Text(
                t('save_btn'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Error View ──
  Widget _buildErrorView(String Function(String) t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFEF4444)),
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

  // ── Main Data View ──
  Widget _buildDataView(BuildContext context, String Function(String) t, bool isDark) {
    final report = _report!;
    final primaryColor = Theme.of(context).primaryColor;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Hero GPA & Attendance cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(child: _buildGpaHeroCard(report.gpa, primaryColor, isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAttendanceHeroCard(report.attendance, isDark)),
                ],
              ),
            ),
          ),

          // AI Warning Banners
          if (_getLocalizedWarnings(report.attendance, t).isNotEmpty)
            SliverToBoxAdapter(
              child: _buildWarningBanners(_getLocalizedWarnings(report.attendance, t), isDark),
            ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicator: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                dividerHeight: 0,
                tabs: [
                  Tab(text: t('attendance_title')),
                  Tab(text: t('grades_title')),
                  Tab(text: t('credits_title')),
                ],
              ),
            ),
          ),

          // Tab Content
          ..._buildTabContent(t, isDark, primaryColor),

          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }

  // ── Localized Warnings ──
  List<String> _getLocalizedWarnings(AttendanceData attendance, String Function(String) t) {
    List<String> warnings = [];

    // Overall warning
    if (attendance.overallPercentage < 80 && attendance.overallPercentage > 0) {
      warnings.add('🚨 ' + t('overall_danger').replaceAll('{pct}', attendance.overallPercentage.toString()));
    } else if (attendance.overallPercentage < 85 && attendance.overallPercentage > 0) {
      warnings.add('⚠️ ' + t('overall_warning').replaceAll('{pct}', attendance.overallPercentage.toString()));
    }

    // Subject warnings
    for (var s in attendance.subjects) {
      final subjName = t(s.name);
      if (s.status == 'danger') {
        warnings.add('🚨 ' + t('risk_danger').replaceAll('{subj}', subjName).replaceAll('{pct}', s.percentage.toString()));
      } else if (s.status == 'warning') {
        if (s.classesCanMiss <= 1) {
          warnings.add('⚠️ ' + t('risk_warning_1').replaceAll('{subj}', subjName));
        } else {
          warnings.add('⚠️ ' + t('risk_warning_n').replaceAll('{subj}', subjName).replaceAll('{n}', s.classesCanMiss.toString()));
        }
      }
    }
    return warnings;
  }

  // ── GPA Hero Card ──
  Widget _buildGpaHeroCard(GpaData gpa, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, size: 16, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                'GPA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                gpa.gpa.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  '/ 4.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${gpa.totalCredits} credits',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Attendance Hero Card ──
  Widget _buildAttendanceHeroCard(AttendanceData att, bool isDark) {
    Color statusColor;
    if (att.status == 'danger') {
      statusColor = const Color(0xFFEF4444);
    } else if (att.status == 'warning') {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_rounded, size: 16, color: statusColor),
              const SizedBox(width: 6),
              Text(
                'DAVOMAT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor.withValues(alpha: 0.8),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${att.overallPercentage}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: att.overallPercentage / 100.0,
              backgroundColor: statusColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Warning Banners ──
  Widget _buildWarningBanners(List<String> warnings, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: warnings.map((w) {
          final isDanger = w.contains('🚨');
          final color = isDanger ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isDanger ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    w.replaceAll(RegExp(r'[🚨⚠️ℹ️]\s*'), ''),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Tab Content Builder ──
  List<Widget> _buildTabContent(String Function(String) t, bool isDark, Color primaryColor) {
    switch (_tabController.index) {
      case 0:
        return _buildAttendanceTab(t, isDark, primaryColor);
      case 1:
        return _buildGradesTab(t, isDark, primaryColor);
      case 2:
        return _buildCreditsTab(t, isDark, primaryColor);
      default:
        return [];
    }
  }

  // ── Attendance Tab ──
  List<Widget> _buildAttendanceTab(String Function(String) t, bool isDark, Color primaryColor) {
    final subjects = _report!.attendance.subjects;

    if (subjects.isEmpty) {
      return [SliverToBoxAdapter(child: _buildEmptyState(t('no_data'), isDark))];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final s = subjects[index];
            final isPending = s.status == 'no_data' || s.totalClasses == 0;

            if (isPending) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t(s.name),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155).withValues(alpha: 0.5)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Text(
                            t('attendance_pending_badge'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t('attendance_not_published'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            Color statusColor;
            if (s.status == 'danger') {
              statusColor = const Color(0xFFEF4444);
            } else if (s.status == 'warning') {
              statusColor = const Color(0xFFF59E0B);
            } else {
              statusColor = const Color(0xFF10B981);
            }

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t(s.name),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${s.percentage}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: s.percentage / 100.0,
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    children: [
                      _buildStatPill('${t('attended')}: ${s.attended}', const Color(0xFF10B981), isDark),
                      const SizedBox(width: 6),
                      _buildStatPill('${t('missed')}: ${s.missed}', const Color(0xFFEF4444), isDark),
                      const SizedBox(width: 6),
                      _buildStatPill('${t('excused')}: ${s.excused}', const Color(0xFFF59E0B), isDark),
                    ],
                  ),
                  if (s.riskMessage != null) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        String getLocalizedMessage() {
                          final subjName = t(s.name);
                          if (s.status == 'danger') {
                            return t('risk_danger')
                                .replaceAll('{subj}', subjName)
                                .replaceAll('{pct}', s.percentage.toString());
                          } else if (s.status == 'warning') {
                            if (s.classesCanMiss <= 1) {
                              return t('risk_warning_1')
                                  .replaceAll('{subj}', subjName);
                            } else {
                              return t('risk_warning_n')
                                  .replaceAll('{subj}', subjName)
                                  .replaceAll('{n}', s.classesCanMiss.toString());
                            }
                          } else {
                            if (s.classesCanMiss <= 2) {
                              return t('risk_safe')
                                  .replaceAll('{subj}', subjName)
                                  .replaceAll('{n}', s.classesCanMiss.toString());
                            }
                          }
                          return s.riskMessage!.replaceAll(RegExp(r'[🚨⚠️ℹ️]\s*'), ''); // Fallback
                        }

                        return Text(
                          getLocalizedMessage(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
          childCount: subjects.length,
        ),
      ),
    ];
  }

  // ── Grades Tab ──
  List<Widget> _buildGradesTab(String Function(String) t, bool isDark, Color primaryColor) {
    final subjects = _report!.currentGrades.subjects;

    if (subjects.isEmpty) {
      return [SliverToBoxAdapter(child: _buildEmptyState(t('no_data'), isDark))];
    }

    return [
      // Overall percentage card
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF1E293B)]
                  : [Colors.white, const Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 10),
              Text(
                '${t('overall')}: ',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '${_report!.currentGrades.overallPercentage}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final s = subjects[index];
            Color statusColor;
            switch (s.status) {
              case 'excellent':
                statusColor = const Color(0xFF10B981);
                break;
              case 'good':
                statusColor = const Color(0xFF3B82F6);
                break;
              case 'needs_work':
                statusColor = const Color(0xFFF59E0B);
                break;
              default:
                statusColor = const Color(0xFFEF4444);
            }

            return Card(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${s.percentage}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                  children: s.assignments.map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            a.deadline,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              a.mark,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
          childCount: subjects.length,
        ),
      ),
    ];
  }

  // ── Credits Tab ──
  List<Widget> _buildCreditsTab(String Function(String) t, bool isDark, Color primaryColor) {
    final gpa = _report!.gpa;

    if (gpa.byGroup.isEmpty) {
      return [SliverToBoxAdapter(child: _buildEmptyState(t('no_data'), isDark))];
    }

    // Grade distribution mini chart
    final gradeColors = {
      'A': const Color(0xFF10B981),
      'B': const Color(0xFF3B82F6),
      'C': const Color(0xFFF59E0B),
      'D': const Color(0xFFF97316),
      'F': const Color(0xFFEF4444),
    };

    return [
      // Grade distribution
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${gpa.totalCredits} ${t('credits_title')} • GPA ${gpa.gpa}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: gradeColors.entries.map((e) {
                  final count = gpa.gradeDistribution[e.key] ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: count,
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: e.value,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: gradeColors.entries.map((e) {
                  final count = gpa.gradeDistribution[e.key] ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: e.value,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${e.key}: $count',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),

      // Groups
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final g = gpa.byGroup[index];
            Color gpaColor;
            if (g.gpa >= 3.5) {
              gpaColor = const Color(0xFF10B981);
            } else if (g.gpa >= 2.5) {
              gpaColor = const Color(0xFF3B82F6);
            } else {
              gpaColor = const Color(0xFFF59E0B);
            }

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: gpaColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school_outlined, size: 20, color: gpaColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${g.count} ${t('credits_title').toLowerCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: gpaColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      g.gpa.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: gpaColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: gpa.byGroup.length,
        ),
      ),
    ];
  }

  // ── Helpers ──
  Widget _buildStatPill(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 40,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
