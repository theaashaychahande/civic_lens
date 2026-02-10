class Announcement {
  final String id;
  final String title;
  final String? description;
  final String? ward;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    this.description,
    this.ward,
    required this.createdAt,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      ward: map['ward'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
