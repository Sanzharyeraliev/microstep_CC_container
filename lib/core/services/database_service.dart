import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/srs_notification.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'microstep.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Таблица папок
    await db.execute('''
      CREATE TABLE folders (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    // Таблица сетов
    await db.execute('''
      CREATE TABLE sets (
        id TEXT PRIMARY KEY,
        folder_id TEXT NOT NULL,
        title TEXT NOT NULL,
        card_ids TEXT NOT NULL,
        color_index INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      );
    ''');

    // Таблица настроек
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    
    // Таблица корзины
    await db.execute('''
      CREATE TABLE trash (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        deleted_at TEXT NOT NULL
      );
    ''');
    
    // Таблица привычек
    await db.execute(''''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_name TEXT NOT NULL
      );
    ''');
    
    // Таблица выполнения привычек
    await db.execute('''
      CREATE TABLE habit_completions (
        habit_id TEXT NOT NULL,
        date TEXT NOT NULL,
        PRIMARY KEY (habit_id, date)
      );
    ''');
    
    // Таблица learning_cards с SRS полями
    await db.execute('''
      CREATE TABLE learning_cards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        color_index INTEGER DEFAULT 0,
        card_type TEXT DEFAULT 'regular',
        srs_interval INTEGER DEFAULT 0,
        srs_ease_factor REAL DEFAULT 2.5,
        srs_review_date TEXT,
        srs_streak INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
    
    // Индексы для learning_cards
    await db.execute('''
      CREATE INDEX idx_learning_cards_category ON learning_cards(category);
    ''');
    await db.execute('''
      CREATE INDEX idx_learning_cards_type ON learning_cards(card_type);
    ''');
    await db.execute('''
      CREATE INDEX idx_learning_cards_review_date ON learning_cards(srs_review_date);
    ''');
    
    // Таблица SRS SERIES
    await db.execute('''
      CREATE TABLE srs_series (
        id TEXT PRIMARY KEY,
        card_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        notification_count INTEGER NOT NULL,
        notifications_sent INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (card_id) REFERENCES learning_cards(id) ON DELETE CASCADE
      );
    ''');
    
    // Индексы для srs_series
    await db.execute('''
      CREATE INDEX idx_srs_series_active ON srs_series(is_active);
    ''');
    await db.execute('''
      CREATE INDEX idx_srs_series_end_date ON srs_series(end_date);
    ''');
    
    // Таблица SRS NOTIFICATIONS
    await db.execute('''
      CREATE TABLE srs_notifications (
        id TEXT PRIMARY KEY,
        series_id TEXT NOT NULL,
        notification_text TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        sent_at TEXT,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (series_id) REFERENCES srs_series(id) ON DELETE CASCADE
      );
    ''');
    
    // Индексы для srs_notifications
    await db.execute('''
      CREATE INDEX idx_srs_notifications_status ON srs_notifications(status);
    ''');
    await db.execute('''
      CREATE INDEX idx_srs_notifications_scheduled ON srs_notifications(scheduled_time);
    ''');
    
    // Таблица НАСТРОЙКИ УВЕДОМЛЕНИЙ
    await db.execute('''
      CREATE TABLE notification_settings (
        module_name TEXT PRIMARY KEY,
        enabled INTEGER DEFAULT 1,
        frequency INTEGER DEFAULT 4,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
    
    // Вставляем настройки по умолчанию
    final now = DateTime.now().toIso8601String();
    final modules = ['declutter', 'journal', 'learn', 'progress', 'habits'];
    for (final module in modules) {
      await db.insert('notification_settings', {
        'module_name': module,
        'enabled': 1,
        'frequency': 4,
        'created_at': now,
        'updated_at': now,
      });
    }
    
    // Добавляем дефолтные папки и сеты
    final defaultFolder = {
      'id': 'folder_default',
      'name': 'My Cards',
      'created_at': now,
    };
    await db.insert('folders', defaultFolder);
    
    final defaultSet = {
      'id': 'set_default',
      'folder_id': 'folder_default',
      'title': 'All Cards',
      'card_ids': '',
      'color_index': 0,
      'created_at': now,
    };
    await db.insert('sets', defaultSet);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE learning_cards (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          color_index INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      ''');
      await db.execute('''
        CREATE INDEX idx_learning_cards_category ON learning_cards(category);
      ''');
    }

    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE learning_cards ADD COLUMN card_type TEXT DEFAULT "regular"');
        await db.execute('ALTER TABLE learning_cards ADD COLUMN srs_interval INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE learning_cards ADD COLUMN srs_ease_factor REAL DEFAULT 2.5');
        await db.execute('ALTER TABLE learning_cards ADD COLUMN srs_review_date TEXT');
        await db.execute('ALTER TABLE learning_cards ADD COLUMN srs_streak INTEGER DEFAULT 0');
        await db.execute('CREATE INDEX idx_learning_cards_type ON learning_cards(card_type)');
        await db.execute('CREATE INDEX idx_learning_cards_review_date ON learning_cards(srs_review_date)');
      } catch (e) {
        debugPrint('Migration error (learning_cards SRS): $e');
      }
      
      try {
        await db.execute('''
          CREATE TABLE srs_series (
            id TEXT PRIMARY KEY,
            card_id TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL,
            notification_count INTEGER NOT NULL,
            notifications_sent INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1
          );
        ''');
        await db.execute('CREATE INDEX idx_srs_series_active ON srs_series(is_active)');
        await db.execute('CREATE INDEX idx_srs_series_end_date ON srs_series(end_date)');
      } catch (e) {
        debugPrint('Migration error (srs_series): $e');
      }
      
      try {
        await db.execute('''
          CREATE TABLE srs_notifications (
            id TEXT PRIMARY KEY,
            series_id TEXT NOT NULL,
            notification_text TEXT NOT NULL,
            scheduled_time TEXT NOT NULL,
            sent_at TEXT,
            status TEXT DEFAULT 'pending'
          );
        ''');
        await db.execute('CREATE INDEX idx_srs_notifications_status ON srs_notifications(status)');
        await db.execute('CREATE INDEX idx_srs_notifications_scheduled ON srs_notifications(scheduled_time)');
      } catch (e) {
        debugPrint('Migration error (srs_notifications): $e');
      }
      
      try {
        await db.execute('''
          CREATE TABLE notification_settings (
            module_name TEXT PRIMARY KEY,
            enabled INTEGER DEFAULT 1,
            frequency INTEGER DEFAULT 4,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        ''');
        
        final now = DateTime.now().toIso8601String();
        final modules = ['declutter', 'journal', 'learn', 'progress', 'habits'];
        for (final module in modules) {
          await db.insert('notification_settings', {
            'module_name': module,
            'enabled': 1,
            'frequency': 4,
            'created_at': now,
            'updated_at': now,
          });
        }
      } catch (e) {
        debugPrint('Migration error (notification_settings): $e');
      }
    }

    if (oldVersion < 4) {
      try {
        await db.execute('''
          CREATE TABLE folders (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE sets (
            id TEXT PRIMARY KEY,
            folder_id TEXT NOT NULL,
            title TEXT NOT NULL,
            card_ids TEXT NOT NULL,
            color_index INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
          );
        ''');
      } catch (e) {
        debugPrint('Migration error (folders/sets): $e');
      }
    }
    
    if (oldVersion < 5) {
      try {
        final now = DateTime.now().toIso8601String();
        
        // Проверяем, есть ли уже дефолтные папки
        final existingFolders = await db.query('folders');
        if (existingFolders.isEmpty) {
          final defaultFolder = {
            'id': 'folder_default',
            'name': 'My Cards',
            'created_at': now,
          };
          await db.insert('folders', defaultFolder);
        }
        
        // Проверяем, есть ли уже дефолтные сеты
        final existingSets = await db.query('sets');
        if (existingSets.isEmpty) {
          final defaultSet = {
            'id': 'set_default',
            'folder_id': 'folder_default',
            'title': 'All Cards',
            'card_ids': '',
            'color_index': 0,
            'created_at': now,
          };
          await db.insert('sets', defaultSet);
        }
      } catch (e) {
        debugPrint('Migration error (default folders/sets): $e');
      }
    }
  }

  // ============ МЕТОДЫ ДЛЯ FOLDERS AND SETS ============
  
  Future<void> insertFolder(Map<String, dynamic> folder) async {
    final db = await database;
    await db.insert('folders', folder);
  }
  
  Future<List<Map<String, dynamic>>> getAllFolders() async {
    final db = await database;
    return await db.query('folders', orderBy: 'created_at DESC');
  }
  
  Future<Map<String, dynamic>?> getFolder(String id) async {
    final db = await database;
    final result = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<void> insertSet(Map<String, dynamic> set) async {
    final db = await database;
    await db.insert('sets', set);
  }
  
  Future<List<Map<String, dynamic>>> getSetsByFolder(String folderId) async {
    final db = await database;
    return await db.query(
      'sets',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'created_at ASC',
    );
  }
  
  Future<Map<String, dynamic>?> getSet(String setId) async {
    final db = await database;
    final result = await db.query('sets', where: 'id = ?', whereArgs: [setId]);
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getAllSets() async {
    final db = await database;
    return await db.query('sets', orderBy: 'created_at DESC');
  }
  
  /// Получить все папки с их сетами (для FolderScreen)
  Future<List<Map<String, dynamic>>> getAllFoldersWithSets() async {
    final db = await database;
    final folders = await db.query('folders', orderBy: 'created_at DESC');
    
    final List<Map<String, dynamic>> result = [];
    for (final folder in folders) {
      final sets = await db.query('sets', where: 'folder_id = ?', whereArgs: [folder['id']]);
      final folderWithSets = Map<String, dynamic>.from(folder);
      folderWithSets['sets'] = sets;
      result.add(folderWithSets);
    }
    return result;
  }
  
  /// Получить или создать дефолтный сет для папки
  Future<String> getOrCreateDefaultSet(String folderId, String setName) async {
    final db = await database;
    final existing = await db.query(
      'sets',
      where: 'folder_id = ? AND title = ?',
      whereArgs: [folderId, setName],
    );
    
    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }
    
    final now = DateTime.now().toIso8601String();
    final setId = 'set_${DateTime.now().millisecondsSinceEpoch}';
    final newSet = {
      'id': setId,
      'folder_id': folderId,
      'title': setName,
      'card_ids': '',
      'color_index': 0,
      'created_at': now,
    };
    
    await db.insert('sets', newSet);
    return setId;
  }
  
  /// Добавить карточку в сет
  Future<void> addCardToSet(String setId, String cardId) async {
    final db = await database;
    final set = await getSet(setId);
    if (set == null) return;
    
    String cardIds = set['card_ids'] as String;
    List<String> ids = cardIds.isEmpty ? [] : cardIds.split(',');
    
    if (!ids.contains(cardId)) {
      ids.add(cardId);
      await db.update('sets', {'card_ids': ids.join(',')}, where: 'id = ?', whereArgs: [setId]);
    }
  }
  
  /// Получить все карточки из конкретного сета
  Future<List<Map<String, dynamic>>> getCardsBySetId(String setId) async {
    final db = await database;
    final set = await getSet(setId);
    if (set == null) return [];
    
    final cardIdsStr = set['card_ids'] as String;
    if (cardIdsStr.isEmpty) return [];
    
    final cardIds = cardIdsStr.split(',');
    if (cardIds.isEmpty) return [];
    
    final placeholders = cardIds.map((_) => '?').join(',');
    final query = 'SELECT * FROM learning_cards WHERE id IN ($placeholders) ORDER BY created_at DESC';
    
    return await db.rawQuery(query, cardIds);
  }
  
  /// Получить количество карточек в сете
  Future<int> getCardCountInSet(String setId) async {
    final cards = await getCardsBySetId(setId);
    return cards.length;
  }

  // ============ МЕТОДЫ ДЛЯ LEARNING CARDS ============
  
  Future<List<Map<String, dynamic>>> getAllLearningCards() async {
    final db = await database;
    return await db.query('learning_cards', orderBy: 'created_at DESC');
  }
  
  Future<Map<String, dynamic>?> getLearningCard(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'learning_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getLearningCardsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'learning_cards',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getSRSCards() async {
    final db = await database;
    return await db.query(
      'learning_cards',
      where: 'card_type = ?',
      whereArgs: ['srs'],
      orderBy: 'srs_review_date ASC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getCardsDueForReview() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.query(
      'learning_cards',
      where: 'card_type = ? AND (srs_review_date IS NULL OR srs_review_date <= ?)',
      whereArgs: ['srs', today],
      orderBy: 'srs_review_date ASC',
    );
  }
  
  Future<List<String>> getAllCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM learning_cards');
    return result.map((row) => row['category'] as String).toList();
  }
  
  Future<void> insertLearningCard(Map<String, dynamic> card) async {
    final db = await database;
    await db.insert('learning_cards', card);
  }
  
  Future<void> updateLearningCard(String id, Map<String, dynamic> card) async {
    final db = await database;
    await db.update(
      'learning_cards',
      card,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> updateSRSCard(String id, {
    required int interval,
    required double easeFactor,
    required DateTime reviewDate,
    required int streak,
  }) async {
    final db = await database;
    await db.update(
      'learning_cards',
      {
        'srs_interval': interval,
        'srs_ease_factor': easeFactor,
        'srs_review_date': reviewDate.toIso8601String(),
        'srs_streak': streak,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> deleteLearningCard(String id) async {
    final db = await database;
    await db.delete('learning_cards', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> getLearningCardsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM learning_cards');
    return result.first['count'] as int;
  }

  // ============ МЕТОДЫ ДЛЯ SRS SERIES ============
  
  Future<void> insertSRSSeries(Map<String, dynamic> series) async {
    final db = await database;
    await db.insert('srs_series', series);
  }
  
  Future<Map<String, dynamic>?> getActiveSRSSeries() async {
    final db = await database;
    final result = await db.query(
      'srs_series',
      where: 'is_active = 1 AND end_date > ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<Map<String, dynamic>?> getSRSSeries(String id) async {
    final db = await database;
    final result = await db.query(
      'srs_series',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<void> incrementSRSSeriesSentCount(String seriesId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE srs_series SET notifications_sent = notifications_sent + 1 WHERE id = ?',
      [seriesId],
    );
  }
  
  Future<void> deactivateSRSSeries(String seriesId) async {
    final db = await database;
    await db.update(
      'srs_series',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [seriesId],
    );
  }
  
  Future<bool> hasActiveSRSSeries() async {
    final series = await getActiveSRSSeries();
    return series != null;
  }

  // ============ МЕТОДЫ ДЛЯ SRS NOTIFICATIONS ============
  
  Future<void> insertSRSNotification(Map<String, dynamic> notification) async {
    final db = await database;
    await db.insert('srs_notifications', notification);
  }
  
  Future<List<SRSNotification>> getPendingSRSNotifications(DateTime now) async {
    final db = await database;
    final result = await db.query(
      'srs_notifications',
      where: 'status = ? AND scheduled_time <= ?',
      whereArgs: ['pending', now.toIso8601String()],
    );
    return result.map((map) => SRSNotification.fromMap(map)).toList();
  }
  
  Future<void> markNotificationAsSent(String id) async {
    final db = await database;
    await db.update(
      'srs_notifications',
      {
        'status': 'sent',
        'sent_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<List<SRSNotification>> getNotificationsBySeries(String seriesId) async {
    final db = await database;
    final result = await db.query(
      'srs_notifications',
      where: 'series_id = ?',
      whereArgs: [seriesId],
      orderBy: 'scheduled_time ASC',
    );
    return result.map((map) => SRSNotification.fromMap(map)).toList();
  }

  // ============ МЕТОДЫ ДЛЯ НАСТРОЕК УВЕДОМЛЕНИЙ ============
  
  Future<Map<String, dynamic>?> getNotificationSettings(String moduleName) async {
    final db = await database;
    final result = await db.query(
      'notification_settings',
      where: 'module_name = ?',
      whereArgs: [moduleName],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getAllNotificationSettings() async {
    final db = await database;
    return await db.query('notification_settings');
  }
  
  Future<void> updateNotificationSettings(String moduleName, {
    bool? enabled,
    int? frequency,
  }) async {
    final db = await database;
    final updates = <String, dynamic>{};
    if (enabled != null) updates['enabled'] = enabled ? 1 : 0;
    if (frequency != null) updates['frequency'] = frequency;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await db.update(
      'notification_settings',
      updates,
      where: 'module_name = ?',
      whereArgs: [moduleName],
    );
  }
  
  Future<void> setModuleNotificationsEnabled(String moduleName, bool enabled) async {
    await updateNotificationSettings(moduleName, enabled: enabled);
  }
  
  Future<void> setModuleNotificationFrequency(String moduleName, int frequency) async {
    await updateNotificationSettings(moduleName, frequency: frequency);
  }
  
  Future<bool> areModuleNotificationsEnabled(String moduleName) async {
    final settings = await getNotificationSettings(moduleName);
    return settings != null ? (settings['enabled'] as int) == 1 : true;
  }
  
  Future<int> getModuleNotificationFrequency(String moduleName) async {
    final settings = await getNotificationSettings(moduleName);
    return settings != null ? (settings['frequency'] as int) : 4;
  }

  // ============ МЕТОДЫ ДЛЯ НАСТРОЕК ============
  
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    return maps.isNotEmpty ? maps.first['value'] as String? : null;
  }

  // ============ МЕТОДЫ ДЛЯ КОРЗИНЫ ============
  
  Future<void> moveToTrash(String id, String type) async {
    final db = await database;
    await db.insert(
      'trash',
      {
        'id': id,
        'type': type,
        'deleted_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteForever(String id) async {
    final db = await database;
    await db.delete('trash', where: 'id = ?', whereArgs: [id]);
  }

  // ============ МЕТОДЫ ДЛЯ ПРИВЫЧЕК ============
  
  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final db = await database;
    return await db.query('habits');
  }

  Future<Set<String>> getCompletedHabitIdsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((map) => map['habit_id'] as String).toSet();
  }

  Future<void> toggleHabitCompleted(String habitId, String date) async {
    final db = await database;
    final completed = (await getCompletedHabitIdsForDate(date)).contains(habitId);

    if (completed) {
      await db.delete(
        'habit_completions',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, date],
      );
    } else {
      await db.insert('habit_completions', {
        'habit_id': habitId,
        'date': date,
      });
    }
  }

  Future<void> addHabit(Map<String, dynamic> habit) async {
    final db = await database;
    await db.insert('habits', habit, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> populateInitialHabits(List<Map<String, dynamic>> habits) async {
    final db = await database;
    final existingHabits = await db.query('habits');
    if (existingHabits.isEmpty) {
      for (final habit in habits) {
        await addHabit(habit);
      }
    }
  }
}