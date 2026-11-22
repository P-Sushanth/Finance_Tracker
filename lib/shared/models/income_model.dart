class IncomeModel {
  final int? id;
  final String source;
  final double amount;
  final String cycleMonth; // Format: 'YYYY-MM'
  final int createdAt; // Unix timestamp in milliseconds

  const IncomeModel({
    this.id,
    required this.source,
    required this.amount,
    required this.cycleMonth,
    required this.createdAt,
  });

  IncomeModel copyWith({
    int? id,
    String? source,
    double? amount,
    String? cycleMonth,
    int? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      cycleMonth: cycleMonth ?? this.cycleMonth,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'source': source,
      'amount': amount,
      'cycle_month': cycleMonth,
      'created_at': createdAt,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as int?,
      source: map['source'] as String,
      amount: (map['amount'] as num).toDouble(),
      cycleMonth: map['cycle_month'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}

