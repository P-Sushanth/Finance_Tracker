class AppSettingModel {
  final String key;
  final String value;

  const AppSettingModel({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  factory AppSettingModel.fromMap(Map<String, dynamic> map) {
    return AppSettingModel(
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }
}

