class GoalModel {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentSaved;
  final double monthlyBudgetAllocation;
  final int? categoryId;
  final int createdAt; // Unix timestamp in milliseconds

  const GoalModel({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentSaved = 0.0,
    this.monthlyBudgetAllocation = 0.0,
    this.categoryId,
    required this.createdAt,
  });

  GoalModel copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentSaved,
    double? monthlyBudgetAllocation,
    int? categoryId,
    int? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSaved: currentSaved ?? this.currentSaved,
      monthlyBudgetAllocation: monthlyBudgetAllocation ?? this.monthlyBudgetAllocation,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_saved': currentSaved,
      'monthly_budget_allocation': monthlyBudgetAllocation,
      'category_id': categoryId,
      'created_at': createdAt,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentSaved: (map['current_saved'] as num?)?.toDouble() ?? 0.0,
      monthlyBudgetAllocation: (map['monthly_budget_allocation'] as num?)?.toDouble() ?? 0.0,
      categoryId: map['category_id'] as int?,
      createdAt: map['created_at'] as int,
    );
  }
}

