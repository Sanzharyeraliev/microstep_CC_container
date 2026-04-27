/// Модель сессии тестирования
class TestSession {
  final String id;
  final DateTime timestamp;
  final int score;
  final int totalQuestions;
  final List<AnswerRecord> answers;
  final String? category;

  TestSession({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    this.category,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions : 0;
  
  String get formattedDate {
    return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}

/// Запись ответа пользователя
class AnswerRecord {
  final String questionId;
  final bool isCorrect;
  final String userAnswer;
  final DateTime answeredAt;

  AnswerRecord({
    required this.questionId,
    required this.isCorrect,
    required this.userAnswer,
    required this.answeredAt,
  });
}