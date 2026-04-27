class SRSNotification {
  final String id;
  final String seriesId;
  final String notificationText;
  final DateTime scheduledTime;
  final DateTime? sentAt;
  final String status; // 'pending', 'sent', 'failed'

  SRSNotification({
    required this.id,
    required this.seriesId,
    required this.notificationText,
    required this.scheduledTime,
    this.sentAt,
    this.status = 'pending',
  });

  factory SRSNotification.fromMap(Map<String, dynamic> map) {
    return SRSNotification(
      id: map['id'] as String,
      seriesId: map['series_id'] as String,
      notificationText: map['notification_text'] as String,
      scheduledTime: DateTime.parse(map['scheduled_time'] as String),
      sentAt: map['sent_at'] != null ? DateTime.parse(map['sent_at'] as String) : null,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'series_id': seriesId,
      'notification_text': notificationText,
      'scheduled_time': scheduledTime.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'status': status,
    };
  }
  
  bool get isSent => status == 'sent';
  bool get isPending => status == 'pending';
}