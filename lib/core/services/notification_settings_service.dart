import 'database_service.dart';

/// Сервис для управления настройками уведомлений по модулям
class NotificationSettingsService {
  final DatabaseService _db = DatabaseService();
  
  /// Получить все настройки
  Future<List<Map<String, dynamic>>> getAllSettings() async {
    return await _db.getAllNotificationSettings();
  }
  
  /// Включить/выключить уведомления для модуля
  Future<void> setModuleEnabled(String moduleName, bool enabled) async {
    await _db.setModuleNotificationsEnabled(moduleName, enabled);
  }
  
  /// Установить частоту уведомлений для модуля
  Future<void> setModuleFrequency(String moduleName, int frequency) async {
    await _db.setModuleNotificationFrequency(moduleName, frequency.clamp(1, 10));
  }
  
  /// Проверить, включены ли уведомления для модуля
  Future<bool> isModuleEnabled(String moduleName) async {
    return await _db.areModuleNotificationsEnabled(moduleName);
  }
  
  /// Получить частоту уведомлений для модуля
  Future<int> getModuleFrequency(String moduleName) async {
    return await _db.getModuleNotificationFrequency(moduleName);
  }
  
  /// Включить все модули
  Future<void> enableAllModules() async {
    final settings = await getAllSettings();
    for (final setting in settings) {
      await setModuleEnabled(setting['module_name'] as String, true);
    }
  }
  
  /// Выключить все модули
  Future<void> disableAllModules() async {
    final settings = await getAllSettings();
    for (final setting in settings) {
      await setModuleEnabled(setting['module_name'] as String, false);
    }
  }
}