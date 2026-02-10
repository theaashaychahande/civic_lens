class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final int points;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.points = 0,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      profilePicture: map['profile_picture'],
      points: map['points'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'points': points,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
