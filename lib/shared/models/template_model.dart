class TemplateModel {
  final int? id;
  final String title;
  final int categoryId;
  final double defaultAmount;
  final String? defaultDescription;
  final int sortOrder;

  const TemplateModel({
    this.id,
    required this.title,
    required this.categoryId,
    required this.defaultAmount,
    this.defaultDescription,
    this.sortOrder = 0,
  });

  TemplateModel copyWith({
    int? id,
    String? title,
    int? categoryId,
    double? defaultAmount,
    String? defaultDescription,
    int? sortOrder,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      defaultDescription: defaultDescription ?? this.defaultDescription,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'category_id': categoryId,
      'default_amount': defaultAmount,
      'default_description': defaultDescription,
      'sort_order': sortOrder,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      categoryId: map['category_id'] as int,
      defaultAmount: (map['default_amount'] as num).toDouble(),
      defaultDescription: map['default_description'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }
}

