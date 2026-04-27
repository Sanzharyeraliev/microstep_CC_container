import '../../models/test_question.dart';
import '../../models/open_question.dart';
import '../../models/learning_card.dart';

/// Абстрактный класс для AI провайдеров
abstract class AIProvider {
  /// Генерация тестовых вопросов (множественный выбор) на основе карточек
  Future<List<TestQuestion>> generateTestQuestions({
    required List<LearningCardModel> cards,
    required int count,
  });
  
  /// Генерация открытого вопроса на основе карточки
  Future<OpenQuestion> generateOpenQuestion({
    required LearningCardModel card,
  });
  
  /// Оценка ответа пользователя на открытый вопрос
  Future<double> evaluateOpenAnswer({
    required OpenQuestion question,
    required String userAnswer,
  });
  /// Генерация контекстного уведомления для SRS карточки
  Future<String> generateNotificationContent({
    required LearningCardModel card,
    required int dayNumber,
    required int totalDays,
  });
}
