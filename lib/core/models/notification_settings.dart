class NotificationSettings {
  final String moduleName;
  final bool enabled;
  final int frequency;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationSettings({
    required this.moduleName,
    required this.enabled,
    required this.frequency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      moduleName: map['module_name'] as String,
      enabled: (map['enabled'] as int) == 1,
      frequency: map['frequency'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'module_name': moduleName,
      'enabled': enabled ? 1 : 0,
      'frequency': frequency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}