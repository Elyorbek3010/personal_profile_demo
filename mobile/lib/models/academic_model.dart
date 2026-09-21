library;

/// Data models for the Academics module.
/// Mirrors the JSON structure returned by GET /api/academics/my-data/

class AcademicReport {
  final String studentName;
  final TurnstileStatus turnstile;
  final GpaData gpa;
  final AttendanceData attendance;
  final CurrentGradesData currentGrades;

  AcademicReport({
    required this.studentName,
    required this.turnstile,
    required this.gpa,
    required this.attendance,
    required this.currentGrades,
  });

  factory AcademicReport.fromJson(Map<String, dynamic> json) {
    return AcademicReport(
      studentName: json['student_name']?.toString() ?? '',
      turnstile: TurnstileStatus.fromJson(json['turnstile'] ?? {}),
      gpa: GpaData.fromJson(json['gpa'] ?? {}),
      attendance: AttendanceData.fromJson(json['attendance'] ?? {}),
      currentGrades: CurrentGradesData.fromJson(json['current_grades'] ?? {}),
    );
  }
}

class TurnstileStatus {
  final bool hasData;
  final String statusText;

  TurnstileStatus({required this.hasData, required this.statusText});

  factory TurnstileStatus.fromJson(Map<String, dynamic> json) {
    return TurnstileStatus(
      hasData: json['has_data'] == true,
      statusText: json['status_text']?.toString() ?? '',
    );
  }
}

class GpaData {
  final double gpa;
  final int totalCredits;
  final Map<String, int> gradeDistribution;
  final List<GpaGroup> byGroup;

  GpaData({
    required this.gpa,
    required this.totalCredits,
    required this.gradeDistribution,
    required this.byGroup,
  });

  factory GpaData.fromJson(Map<String, dynamic> json) {
    final distRaw = json['grade_distribution'] as Map<String, dynamic>? ?? {};
    final dist = distRaw.map((k, v) => MapEntry(k, v is int ? v : int.tryParse(v.toString()) ?? 0));

    final groupsRaw = json['by_group'] as List? ?? [];
    final groups = groupsRaw.map((g) => GpaGroup.fromJson(g)).toList();

    return GpaData(
      gpa: (json['gpa'] is num) ? (json['gpa'] as num).toDouble() : double.tryParse(json['gpa']?.toString() ?? '0') ?? 0.0,
      totalCredits: json['total_credits'] is int ? json['total_credits'] : int.tryParse(json['total_credits']?.toString() ?? '0') ?? 0,
      gradeDistribution: dist,
      byGroup: groups,
    );
  }
}

class GpaGroup {
  final String name;
  final double gpa;
  final int count;

  GpaGroup({required this.name, required this.gpa, required this.count});

  factory GpaGroup.fromJson(Map<String, dynamic> json) {
    return GpaGroup(
      name: json['name']?.toString() ?? '',
      gpa: (json['gpa'] is num) ? (json['gpa'] as num).toDouble() : 0.0,
      count: json['count'] is int ? json['count'] : 0,
    );
  }
}

class AttendanceData {
  final int overallPercentage;
  final String status; // 'safe', 'warning', 'danger'
  final List<AttendanceSubject> subjects;
  final List<String> warnings;

  AttendanceData({
    required this.overallPercentage,
    required this.status,
    required this.subjects,
    required this.warnings,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    final subjectsRaw = json['subjects'] as List? ?? [];
    final warningsRaw = json['warnings'] as List? ?? [];

    return AttendanceData(
      overallPercentage: json['overall_percentage'] is int ? json['overall_percentage'] : 0,
      status: json['status']?.toString() ?? 'unknown',
      subjects: subjectsRaw.map((s) => AttendanceSubject.fromJson(s)).toList(),
      warnings: warningsRaw.map((w) => w.toString()).toList(),
    );
  }
}

class AttendanceSubject {
  final String name;
  final int percentage;
  final int totalClasses;
  final int attended;
  final int missed;
  final int excused;
  final String status;
  final String? riskMessage;
  final int classesCanMiss;

  AttendanceSubject({
    required this.name,
    required this.percentage,
    required this.totalClasses,
    required this.attended,
    required this.missed,
    required this.excused,
    required this.status,
    this.riskMessage,
    required this.classesCanMiss,
  });

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) {
    return AttendanceSubject(
      name: json['name']?.toString() ?? '',
      percentage: json['percentage'] is int ? json['percentage'] : 0,
      totalClasses: json['total_classes'] is int ? json['total_classes'] : 0,
      attended: json['attended'] is int ? json['attended'] : 0,
      missed: json['missed'] is int ? json['missed'] : 0,
      excused: json['excused'] is int ? json['excused'] : 0,
      status: json['status']?.toString() ?? 'unknown',
      riskMessage: json['risk_message']?.toString(),
      classesCanMiss: json['classes_can_miss'] is int ? json['classes_can_miss'] : 0,
    );
  }
}

class CurrentGradesData {
  final int overallPercentage;
  final List<GradeSubject> subjects;

  CurrentGradesData({required this.overallPercentage, required this.subjects});

  factory CurrentGradesData.fromJson(Map<String, dynamic> json) {
    final subjectsRaw = json['subjects'] as List? ?? [];
    return CurrentGradesData(
      overallPercentage: json['overall_percentage'] is int ? json['overall_percentage'] : 0,
      subjects: subjectsRaw.map((s) => GradeSubject.fromJson(s)).toList(),
    );
  }
}

class GradeSubject {
  final String name;
  final int percentage;
  final String status; // 'excellent', 'good', 'needs_work', 'failing'
  final List<Assignment> assignments;

  GradeSubject({
    required this.name,
    required this.percentage,
    required this.status,
    required this.assignments,
  });

  factory GradeSubject.fromJson(Map<String, dynamic> json) {
    final assignmentsRaw = json['assignments'] as List? ?? [];
    return GradeSubject(
      name: json['name']?.toString() ?? '',
      percentage: json['percentage'] is int ? json['percentage'] : 0,
      status: json['status']?.toString() ?? 'unknown',
      assignments: assignmentsRaw.map((a) => Assignment.fromJson(a)).toList(),
    );
  }
}

class Assignment {
  final String name;
  final String mark;
  final String deadline;

  Assignment({required this.name, required this.mark, required this.deadline});

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      name: json['name']?.toString() ?? '',
      mark: json['mark']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
    );
  }
}
