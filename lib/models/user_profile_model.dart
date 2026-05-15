import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final String preferredLanguage;
  final bool darkMode;
  final Map<String, dynamic> readingStats;

  UserProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.preferredLanguage = 'id',
    this.darkMode = false,
    this.readingStats = const {},
  });

  factory UserProfileModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfileModel(
      uid: uid,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferredLanguage: data['preferredLanguage'] as String? ?? 'id',
      darkMode: data['darkMode'] as bool? ?? false,
      readingStats: data['readingStats'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferredLanguage': preferredLanguage,
      'darkMode': darkMode,
      'readingStats': readingStats,
    };
  }

  UserProfileModel copyWith({
    String? displayName,
    String? photoUrl,
    String? preferredLanguage,
    bool? darkMode,
    Map<String, dynamic>? readingStats,
  }) {
    return UserProfileModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      darkMode: darkMode ?? this.darkMode,
      readingStats: readingStats ?? this.readingStats,
    );
  }
}
