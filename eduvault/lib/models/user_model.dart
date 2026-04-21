import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? fullName;

  @HiveField(2)
  String? schoolName;

  @HiveField(3)
  String? board;

  @HiveField(4)
  String? collegeName;

  @HiveField(5)
  String? universityName;

  @HiveField(6)
  String? state;

  @HiveField(7)
  String? country;

  @HiveField(8)
  List<String>? targetExams;

  @HiveField(9)
  DateTime? createdAt;

  @HiveField(10)
  DateTime? updatedAt;

  @HiveField(11)
  bool? isProfileComplete;

  UserProfile({
    this.id,
    this.fullName,
    this.schoolName,
    this.board,
    this.collegeName,
    this.universityName,
    this.state,
    this.country,
    this.targetExams,
    this.createdAt,
    this.updatedAt,
    this.isProfileComplete = false,
  });

  /// Create a copy of UserProfile with some fields replaced
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? schoolName,
    String? board,
    String? collegeName,
    String? universityName,
    String? state,
    String? country,
    List<String>? targetExams,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      board: board ?? this.board,
      collegeName: collegeName ?? this.collegeName,
      universityName: universityName ?? this.universityName,
      state: state ?? this.state,
      country: country ?? this.country,
      targetExams: targetExams ?? this.targetExams,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'schoolName': schoolName,
      'board': board,
      'collegeName': collegeName,
      'universityName': universityName,
      'state': state,
      'country': country,
      'targetExams': targetExams,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['fullName'],
      schoolName: json['schoolName'],
      board: json['board'],
      collegeName: json['collegeName'],
      universityName: json['universityName'],
      state: json['state'],
      country: json['country'],
      targetExams: List<String>.from(json['targetExams'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }
}
