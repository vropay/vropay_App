class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? profession;
  final String? mobile;
  final List<String>? selectedTopics;
  final String? difficultyLevel;
  final String? communityAccess;
  final bool? notificationsEnabled;
  final bool? isOnboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.profession,
    this.mobile,
    this.selectedTopics,
    this.difficultyLevel,
    this.communityAccess,
    this.notificationsEnabled,
    this.isOnboardingCompleted,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      profession: json['profession'],
      mobile: json['mobile'],
      selectedTopics: json['selectedTopics'] != null 
          ? List<String>.from(json['selectedTopics']) 
          : null,
      difficultyLevel: json['difficultyLevel'],
      communityAccess: json['communityAccess'],
      notificationsEnabled: json['notificationsEnabled'],
      isOnboardingCompleted: json['isOnboardingCompleted'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'profession': profession,
      'mobile': mobile,
      'selectedTopics': selectedTopics,
      'difficultyLevel': difficultyLevel,
      'communityAccess': communityAccess,
      'notificationsEnabled': notificationsEnabled,
      'isOnboardingCompleted': isOnboardingCompleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
