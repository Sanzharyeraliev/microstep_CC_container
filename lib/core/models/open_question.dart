/// Модель открытого вопроса (пользователь пишет ответ)
class OpenQuestion {
  final String id;
  final String cardId;        // ID карточки, из которой сгенерирован вопрос
  final String term;          // Термин/понятие
  final String questionText;  // Текст вопроса (обычно термин)
  final List<String> expectedKeywords;  // Ключевые слова для оценки
  final String sampleAnswer;  // Пример правильного ответа
  final String? category;

  OpenQuestion({
    required this.id,
    required this.cardId,
    required this.term,
    required this.questionText,
    required this.expectedKeywords,
    required this.sampleAnswer,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'term': term,
      'question_text': questionText,
      'expected_keywords': expectedKeywords,
      'sample_answer': sampleAnswer,
      'category': category,
    };
  }

  factory OpenQuestion.fromMap(Map<String, dynamic> map) {
    return OpenQuestion(
      id: map['id'] as String,
      cardId: map['card_id'] as String,
      term: map['term'] as String,
      questionText: map['question_text'] as String,
      expectedKeywords: List<String>.from(map['expected_keywords'] as List),
      sampleAnswer: map['sample_answer'] as String,
      category: map['category'] as String?,
    );
  }

  /// Оценить ответ пользователя (0.0 - 1.0)
  double evaluateAnswer(String userAnswer) {
    if (userAnswer.trim().isEmpty) return 0.0;
    
    final lowerAnswer = userAnswer.toLowerCase();
    int matchedKeywords = 0;
    
    for (final keyword in expectedKeywords) {
      if (lowerAnswer.contains(keyword.toLowerCase())) {
        matchedKeywords++;
      }
    }
    
    return matchedKeywords / expectedKeywords.length;
  }
}