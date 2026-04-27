import '../services/database_service.dart';
import '../models/learning_card.dart';

class LearningCardRepository {
  final DatabaseService _db = DatabaseService();

  /// Получить все карточки
  Future<List<LearningCardModel>> getAllCards() async {
    final maps = await _db.getAllLearningCards();
    return maps.map((map) => LearningCardModel.fromMap(map)).toList();
  }

  /// Получить карточку по ID
  Future<LearningCardModel?> getCardById(String id) async {
    final map = await _db.getLearningCard(id);
    if (map == null) return null;
    return LearningCardModel.fromMap(map);
  }

  /// Получить карточки по категории
  Future<List<LearningCardModel>> getCardsByCategory(String category) async {
    final maps = await _db.getLearningCardsByCategory(category);
    return maps.map((map) => LearningCardModel.fromMap(map)).toList();
  }

  /// Получить все категории
  Future<List<String>> getAllCategories() async {
    return await _db.getAllCategories();
  }

  /// Сохранить карточку (добавить или обновить)
  Future<void> saveCard(LearningCardModel card) async {
    final existing = await getCardById(card.id);
    if (existing == null) {
      await _db.insertLearningCard(card.toMap());
    } else {
      await _db.updateLearningCard(card.id, card.toMap());
    }
  }

  /// Добавить новую карточку
  Future<void> addCard(LearningCardModel card) async {
    await _db.insertLearningCard(card.toMap());
  }

  /// Обновить карточку
  Future<void> updateCard(LearningCardModel card) async {
    await _db.updateLearningCard(card.id, card.toMap());
  }

  /// Удалить карточку
  Future<void> deleteCard(String id) async {
    await _db.deleteLearningCard(id);
  }

  /// Получить количество карточек
  Future<int> getCardsCount() async {
    return await _db.getLearningCardsCount();
  }

  /// Проверить, есть ли карточки
  Future<bool> hasCards() async {
    final count = await getCardsCount();
    return count > 0;
  }
}