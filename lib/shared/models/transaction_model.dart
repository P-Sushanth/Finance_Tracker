class TransactionModel {
  final int? id;
  final int categoryId;
  final double amount;
  final String? description;
  final String cycleMonth; // Format: 'YYYY-MM'
  final int createdAt; // Unix timestamp in milliseconds

  const TransactionModel({
    this.id,
    required this.categoryId,
    required this.amount,
    this.description,
    required this.cycleMonth,
    required this.createdAt,
  });

  TransactionModel copyWith({
    int? id,
    int? categoryId,
    double? amount,
    String? description,
    String? cycleMonth,
    int? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      cycleMonth: cycleMonth ?? this.cycleMonth,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'cycle_month': cycleMonth,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      cycleMonth: map['cycle_month'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}

