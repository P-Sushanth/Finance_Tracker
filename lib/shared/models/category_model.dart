enum CategoryType {
  expense,
  investment;

  String toDbValue() {
    switch (this) {
      case CategoryType.expense:
        return 'EXPENSE';
      case CategoryType.investment:
        return 'INVESTMENT';
    }
  }

  static CategoryType fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'INVESTMENT':
        return CategoryType.investment;
      case 'EXPENSE':
      default:
        return CategoryType.expense;
    }
  }
}

class CategoryModel {
  final int? id;
  final String name;
  final double budgetLimit;
  final CategoryType type;
  final String? iconName;
  final int sortOrder;
  final bool isArchived;

  const CategoryModel({
    this.id,
    required this.name,
    required this.budgetLimit,
    required this.type,
    this.iconName,
    this.sortOrder = 0,
    this.isArchived = false,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    double? budgetLimit,
    CategoryType? type,
    String? iconName,
    int? sortOrder,
    bool? isArchived,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'budget_limit': budgetLimit,
      'type': type.toDbValue(),
      'icon_name': iconName,
      'sort_order': sortOrder,
      'is_archived': isArchived ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      budgetLimit: (map['budget_limit'] as num).toDouble(),
      type: CategoryType.fromDbValue(map['type'] as String),
      iconName: map['icon_name'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      isArchived: (map['is_archived'] as int?) == 1,
    );
  }
}

