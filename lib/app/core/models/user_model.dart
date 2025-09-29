class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  String? gender;
  final String? profession;
  final String? mobile;
  final String? profileImage;
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
    this.profileImage,
    this.selectedTopics,
    this.difficultyLevel,
    this.communityAccess,
    this.notificationsEnabled,
    this.isOnboardingCompleted,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle interests array and extract names
    List<String>? interestIds;
    if (json['interests'] != null && json['interests'] is List) {
      interestIds = (json['interests'] as List)
          .map((interest) => interest['_id']?.toString() ?? interest.toString())
          .where((id) => id.isNotEmpty)
          .toList();
    }
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      profession: json['profession'],
      mobile: json['mobile'],
      profileImage: json['profileImage'] ?? json['avatar'],
      selectedTopics: interestIds,
      difficultyLevel: json['difficulty'] ?? json['difficultyLevel'],
      communityAccess: json['community'] ?? json['communityAccess'],
      notificationsEnabled: json['notifications'] == 'Allowed' ||
          json['notificationsEnabled'] == true,
      isOnboardingCompleted: json['isOnboardingCompleted'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
      'profileImage': profileImage,
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
