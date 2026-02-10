enum IssueStatus { reported, verified, in_progress, resolved }
enum IssuePriority { high, medium, low }

class Issue {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final IssueStatus status;
  final IssuePriority priority;
  final DateTime createdAt;
  final int verificationsCount;

  Issue({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.verificationsCount = 0,
  });

  factory Issue.fromMap(Map<String, dynamic> map) {
    return Issue(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      imageUrl: map['image_url'],
      status: IssueStatus.values.firstWhere((e) => e.name == map['status']),
      priority: IssuePriority.values.firstWhere((e) => e.name == map['priority']),
      createdAt: DateTime.parse(map['created_at']),
      verificationsCount: map['verifications_count'] ?? 0,
    );
  }
}

