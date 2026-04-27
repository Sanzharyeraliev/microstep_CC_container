/// Модель вопроса для теста (множественный выбор)
class TestQuestion {
  final String id;
  final String cardId;        // ID карточки, из которой сгенерирован вопрос
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String? category;

  TestQuestion({
    required this.id,
    required this.cardId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'question_text': questionText,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
      'category': category,
    };
  }

  factory TestQuestion.fromMap(Map<String, dynamic> map) {
    return TestQuestion(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      questionText: map['question_text'] as String,
      options: List<String>.from(map['options'] as List),
      correctOptionIndex: map['correct_option_index'] as int,
      explanation: map['explanation'] as String,
      category: map['category'] as String?,
    );
  }

  /// Проверка, правильный ли ответ
  bool isCorrect(int selectedIndex) => selectedIndex == correctOptionIndex;
  
  /// Получить букву варианта (A, B, C, D)
  String getOptionLetter(int index) => String.fromCharCode(65 + index);
}