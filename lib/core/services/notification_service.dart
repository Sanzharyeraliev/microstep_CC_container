import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'database_service.dart';

/// Универсальный сервис уведомлений для всех модулей
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  Timer? _periodicCheckTimer;
  
  // Каналы для Android
  static const String _defaultChannelId = 'microstep_default';
  static const String _srsChannelId = 'microstep_srs';
  
  Future<void> initialize() async {
    // Инициализация timezone для точного планирования
    tz.initializeTimeZones();
    
    // Настройка каналов для Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
    
    // Запускаем периодическую проверку для SRS (каждые 30 минут)
    _periodicCheckTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _checkAndSendSRSNotifications();
    });
    
    // Проверяем сразу при запуске
    _checkAndSendSRSNotifications();
  }
  
  void dispose() {
    _periodicCheckTimer?.cancel();
  }
  
  // ============ БАЗОВЫЕ МЕТОДЫ ============
  
  /// Показать простое уведомление
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    NotificationType? type,
    String? payload,
  }) async {
    // Проверяем, включены ли уведомления для этого модуля
    if (type != null) {
      final enabled = await DatabaseService().areModuleNotificationsEnabled(type.moduleName);
      if (!enabled) return;
    }
    
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    final iosDetails = DarwinNotificationDetails();
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details, payload: payload);
  }
  
  /// Запланировать уведомление на определённое время
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotificationType? type,
    String? payload,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;
    
    // Проверяем, включены ли уведомления для этого модуля
    if (type != null) {
      final enabled = await DatabaseService().areModuleNotificationsEnabled(type.moduleName);
      if (!enabled) return;
    }
    
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: Importance.high,
      priority: Priority.high,
    );
    
    final iosDetails = DarwinNotificationDetails();
    
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  /// Отменить уведомление
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // ============ МЕТОДЫ ДЛЯ РАЗНЫХ МОДУЛЕЙ ============
  
  /// Уведомление от Declutter
  Future<void> showDeclutterNotification({
    required String itemName,
    String? action,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final title = '🧹 Declutter Reminder';
    final body = action != null 
        ? '"$itemName" is waiting for you to $action'
        : 'Time to review "$itemName" in your declutter list';
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.declutter,
    );
  }
  
  /// Уведомление от Journal
  Future<void> showJournalNotification({
    String? prompt,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final title = '📔 Journal Reflection';
    final body = prompt ?? 'Take a moment to write about your day';
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.journal,
    );
  }
  
  /// Уведомление от Learn (обычные карточки)
  Future<void> showLearnNotification({
    required String term,
    required String definition,
    String? context,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final title = '📚 Word of the Day: $term';
    final body = context ?? definition;
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.learn,
    );
  }
  
  /// Уведомление от Progress
  Future<void> showProgressNotification({
    required String metric,
    required int currentValue,
    required int targetValue,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final title = '📈 Progress Update';
    final body = '$metric: $currentValue/$targetValue — Keep going!';
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.progress,
    );
  }
  
  /// Уведомление от Habits
  Future<void> showHabitNotification({
    required String habitName,
    String? reminderTime,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final title = '✅ Habit Reminder';
    final body = reminderTime != null 
        ? 'Time to complete "$habitName" ($reminderTime)'
        : 'Don\'t forget to complete "$habitName" today!';
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.habits,
    );
  }
  
  /// Уведомление от SRS (Spaced Repetition)
  Future<void> showSRSNotification({
    required String term,
    required String definition,
    required int dayNumber,
    required int totalDays,
    String? context,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final title = '🧠 SRS Review: $term';
    final body = context ?? '$definition — Day $dayNumber of $totalDays';
    
    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.srs,
    );
  }
  
  // ============ ПЕРИОДИЧЕСКИЕ УВЕДОМЛЕНИЯ ============
  
  /// Запланировать ежедневное уведомление
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    NotificationType? type,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      type: type,
    );
  }
  
  // ============ SRS СПЕЦИФИЧНЫЕ МЕТОДЫ ============
  
  /// Проверка и отправка SRS уведомлений
  Future<void> _checkAndSendSRSNotifications() async {
    final db = DatabaseService();
    final pendingNotifications = await db.getPendingSRSNotifications(DateTime.now());
    
    for (final notification in pendingNotifications) {
      // Получаем карточку для уведомления
      final series = await db.getSRSSeries(notification.seriesId);
      if (series == null) continue;
      
      final card = await db.getLearningCard(series['card_id'] as String);
      if (card == null) continue;
      
      // Отправляем уведомление с контекстом
      await showSRSNotification(
        term: card['title'] as String,
        definition: card['description'] as String,
        dayNumber: (series['notifications_sent'] as int) + 1,
        totalDays: series['notification_count'] as int,
        context: notification.notificationText,
      );
      
      // Обновляем статус
      await db.markNotificationAsSent(notification.id);
      await db.incrementSRSSeriesSentCount(notification.seriesId);
    }
  }
  
  // ============ HELPER МЕТОДЫ ============
  
  String _getChannelId(NotificationType? type) {
    if (type == null) return _defaultChannelId;
    switch (type) {
      case NotificationType.srs:
        return _srsChannelId;
      default:
        return _defaultChannelId;
    }
  }
  
  String _getChannelName(NotificationType? type) {
    if (type == null) return 'MicroStep';
    switch (type) {
      case NotificationType.srs:
        return 'SRS Learning';
      default:
        return type.displayName;
    }
  }
  
  String _getChannelDescription(NotificationType? type) {
    if (type == null) return 'General notifications';
    switch (type) {
      case NotificationType.srs:
        return 'Spaced repetition system reminders';
      default:
        return '${type.displayName} notifications';
    }
  }
  
  /// Запросить разрешение на уведомления (для iOS)
  Future<void> requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

/// Типы уведомлений для разных модулей
enum NotificationType {
  declutter,
  journal,
  learn,
  progress,
  habits,
  srs,
}

extension NotificationTypeExtension on NotificationType {
  String get moduleName {
    switch (this) {
      case NotificationType.declutter:
        return 'declutter';
      case NotificationType.journal:
        return 'journal';
      case NotificationType.learn:
        return 'learn';
      case NotificationType.progress:
        return 'progress';
      case NotificationType.habits:
        return 'habits';
      case NotificationType.srs:
        return 'srs';
    }
  }
  
  String get displayName {
    switch (this) {
      case NotificationType.declutter:
        return 'Declutter';
      case NotificationType.journal:
        return 'Journal';
      case NotificationType.learn:
        return 'Learn';
      case NotificationType.progress:
        return 'Progress';
      case NotificationType.habits:
        return 'Habits';
      case NotificationType.srs:
        return 'SRS Learning';
    }
  }
  
  IconData get icon {
    switch (this) {
      case NotificationType.declutter:
        return Icons.inventory_2;
      case NotificationType.journal:
        return Icons.menu_book;
      case NotificationType.learn:
        return Icons.school;
      case NotificationType.progress:
        return Icons.trending_up;
      case NotificationType.habits:
        return Icons.check_circle;
      case NotificationType.srs:
        return Icons.psychology;
    }
  }
}