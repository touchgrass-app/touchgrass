class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActive;
  final String? avatarUrl;
  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.lastActive,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }
}
