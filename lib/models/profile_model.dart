class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? bio;
  final String? profilePictureUrl;
  final String createdAt;
  final String lastModifiedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.bio,
    this.profilePictureUrl,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String? ?? '',
        bio: json['bio'] as String?,
        profilePictureUrl: json['profilePictureUrl'] as String?,
        createdAt: json['createdAt'] as String,
        lastModifiedAt: json['lastModifiedAt'] as String,
      );
}
