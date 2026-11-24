class FuturePlan {
  final String id;
  final String title;
  final String details;
  final DateTime createdAt;

  FuturePlan({
    required this.id,
    required this.title,
    required this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FuturePlan.fromMap(Map map) {
    return FuturePlan(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}