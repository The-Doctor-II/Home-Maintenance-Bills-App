class Invoice {
  final String id;
  final String name;
  final double amount;
  final String details;
  final String category;
  final DateTime date;
  final bool isPaid;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.name,
    required this.amount,
    required this.details,
    required this.category,
    required this.date,
    required this.isPaid,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'details': details,
      'category': category,
      'date': date.toIso8601String(),
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map map) {
    return Invoice(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      details: map['details'] ?? '',
      category: map['category'] ?? 'أخرى',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      isPaid: map['isPaid'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}