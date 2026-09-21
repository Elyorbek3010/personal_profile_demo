class TimetableClassModel {
  final int id;
  final String semester;
  final int dayIndex;
  final String dayName;
  final int period;
  final String startTime;
  final String endTime;
  final String startTimeFormatted;
  final String endTimeFormatted;
  final String timeSlot;
  final String subject;
  final String teacher;
  final String room;
  final List<String> groups;
  final String targetPartner;
  final bool isJapanese;
  final String classType;
  final String notes;

  TimetableClassModel({
    required this.id,
    required this.semester,
    required this.dayIndex,
    required this.dayName,
    required this.period,
    required this.startTime,
    required this.endTime,
    required this.startTimeFormatted,
    required this.endTimeFormatted,
    required this.timeSlot,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.groups,
    required this.targetPartner,
    required this.isJapanese,
    required this.classType,
    required this.notes,
  });

  factory TimetableClassModel.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['groups'];
    List<String> parsedGroups = [];
    if (rawGroups is List) {
      parsedGroups = rawGroups.map((e) => e.toString()).toList();
    }

    return TimetableClassModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      semester: json['semester']?.toString() ?? '',
      dayIndex: json['day_index'] is int ? json['day_index'] : int.tryParse(json['day_index']?.toString() ?? '0') ?? 0,
      dayName: json['day_name']?.toString() ?? '',
      period: json['period'] is int ? json['period'] : int.tryParse(json['period']?.toString() ?? '1') ?? 1,
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      startTimeFormatted: json['start_time_formatted']?.toString() ?? '',
      endTimeFormatted: json['end_time_formatted']?.toString() ?? '',
      timeSlot: json['time_slot']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      groups: parsedGroups,
      targetPartner: json['target_partner']?.toString() ?? 'ALL',
      isJapanese: json['is_japanese'] == true,
      classType: json['class_type']?.toString() ?? 'lecture',
      notes: json['notes']?.toString() ?? '',
    );
  }
}

class DayScheduleModel {
  final int dayIndex;
  final String dayName;
  final int classesCount;
  final List<TimetableClassModel> classes;

  DayScheduleModel({
    required this.dayIndex,
    required this.dayName,
    required this.classesCount,
    required this.classes,
  });

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    var rawClasses = json['classes'] as List? ?? [];
    List<TimetableClassModel> parsedClasses = rawClasses
        .map((e) => TimetableClassModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DayScheduleModel(
      dayIndex: json['day_index'] is int ? json['day_index'] : int.tryParse(json['day_index']?.toString() ?? '0') ?? 0,
      dayName: json['day_name']?.toString() ?? '',
      classesCount: json['classes_count'] is int ? json['classes_count'] : int.tryParse(json['classes_count']?.toString() ?? '0') ?? parsedClasses.length,
      classes: parsedClasses,
    );
  }
}

class NextClassResponse {
  final bool hasNextClass;
  final bool isToday;
  final String dayName;
  final TimetableClassModel? nextClass;

  NextClassResponse({
    required this.hasNextClass,
    required this.isToday,
    required this.dayName,
    this.nextClass,
  });

  factory NextClassResponse.fromJson(Map<String, dynamic> json) {
    var rawClass = json['next_class'];
    TimetableClassModel? parsedClass;
    if (rawClass is Map<String, dynamic>) {
      parsedClass = TimetableClassModel.fromJson(rawClass);
    }

    return NextClassResponse(
      hasNextClass: json['has_next_class'] == true,
      isToday: json['is_today'] == true,
      dayName: json['day_name']?.toString() ?? '',
      nextClass: parsedClass,
    );
  }
}
