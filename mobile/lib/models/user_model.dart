class UserModel {
  final int id;
  final String email;
  final String username;
  final String name;
  final String firstName;
  final String lastName;
  final String studentId;
  final String group;
  final String course;
  final String direction;
  final String partnerUniversity;
  final bool japaneseExempt;
  final String japaneseLevel;
  final String avatar;
  final bool isVerified;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.group,
    required this.course,
    required this.direction,
    required this.partnerUniversity,
    required this.japaneseExempt,
    this.japaneseLevel = 'N3',
    required this.avatar,
    required this.isVerified,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      course: json['course']?.toString() ?? '',
      direction: json['direction']?.toString() ?? '',
      partnerUniversity: json['partnerUniversity']?.toString() ?? '',
      japaneseExempt: json['japaneseExempt'] == true,
      japaneseLevel: json['japaneseLevel']?.toString() ?? 'N3',
      avatar: json['avatar']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      role: json['role']?.toString() ?? 'student',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'studentId': studentId,
      'group': group,
      'course': course,
      'direction': direction,
      'partnerUniversity': partnerUniversity,
      'japaneseExempt': japaneseExempt,
      'japaneseLevel': japaneseLevel,
      'avatar': avatar,
      'isVerified': isVerified,
      'role': role,
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? username,
    String? name,
    String? firstName,
    String? lastName,
    String? studentId,
    String? group,
    String? course,
    String? direction,
    String? partnerUniversity,
    bool? japaneseExempt,
    String? japaneseLevel,
    String? avatar,
    bool? isVerified,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentId: studentId ?? this.studentId,
      group: group ?? this.group,
      course: course ?? this.course,
      direction: direction ?? this.direction,
      partnerUniversity: partnerUniversity ?? this.partnerUniversity,
      japaneseExempt: japaneseExempt ?? this.japaneseExempt,
      japaneseLevel: japaneseLevel ?? this.japaneseLevel,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
    );
  }
}
