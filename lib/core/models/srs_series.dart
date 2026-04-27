class SRSSeries {
  final String id;
  final String cardId;
  final DateTime startDate;
  final DateTime endDate;
  final int notificationCount;
  final int notificationsSent;
  final bool isActive;

  SRSSeries({
    required this.id,
    required this.cardId,
    required this.startDate,
    required this.endDate,
    required this.notificationCount,
    required this.notificationsSent,
    required this.isActive,
  });

  factory SRSSeries.fromMap(Map<String, dynamic> map) {
    return SRSSeries(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      notificationCount: map['notification_count'] as int,
      notificationsSent: map['notifications_sent'] as int,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'notification_count': notificationCount,
      'notifications_sent': notificationsSent,
      'is_active': isActive ? 1 : 0,
    };
  }

  double get progress => notificationsSent / notificationCount;
  
  bool get isCompleted => notificationsSent >= notificationCount;
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  
  int get remainingDays => DateTime.now().isAfter(endDate) 
      ? 0 
      : endDate.difference(DateTime.now()).inDays;
}