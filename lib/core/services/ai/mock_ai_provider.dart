import '../../models/test_question.dart';
import '../../models/open_question.dart';
import '../../models/learning_card.dart';
import 'ai_provider.dart';

/// Заглушка AI (для оффлайн-режима или разработки)
class MockAIProvider implements AIProvider {
  
  @override
  Future<List<TestQuestion>> generateTestQuestions({
    required List<LearningCardModel> cards,
    required int count,
  }) async {
    // Имитируем задержку AI
    await Future.delayed(const Duration(milliseconds: 800));
    
    final questions = <TestQuestion>[];
    final availableCards = cards.toList();
    
    for (int i = 0; i < count && i < availableCards.length; i++) {
      final card = availableCards[i % availableCards.length];
      
      // Генерируем 3 фальшивых варианта ответа
      final fakeOptions = [
        'This is a common misconception',
        'A completely different concept',
        'An unrelated term from another category',
      ];
      
      questions.add(TestQuestion(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}_$i',
        cardId: card.id,
        questionText: 'What is "${card.title}"?',
        options: [card.description, ...fakeOptions],
        correctOptionIndex: 0,
        explanation: 'The correct answer is: ${card.description}',
        category: card.category,
      ));
    }
    
    return questions;
  }
  
  @override
  Future<OpenQuestion> generateOpenQuestion({
    required LearningCardModel card,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return OpenQuestion(
      id: 'mock_open_${DateTime.now().millisecondsSinceEpoch}',
      cardId: card.id,
      term: card.title,
      questionText: card.title,
      expectedKeywords: card.title.toLowerCase().split(' '),
      sampleAnswer: card.description,
      category: card.category,
    );
  }
  
  @override
  Future<double> evaluateOpenAnswer({
    required OpenQuestion question,
    required String userAnswer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (userAnswer.trim().isEmpty) return 0.0;
    
    // Простая проверка по ключевым словам
    final lowerAnswer = userAnswer.toLowerCase();
    int matched = 0;
    
    for (final keyword in question.expectedKeywords) {
      if (lowerAnswer.contains(keyword.toLowerCase())) {
        matched++;
      }
    }
    
    return matched / question.expectedKeywords.length;
  }
  
  @override
  Future<String> generateNotificationContent({
    required LearningCardModel card,
    required int dayNumber,
    required int totalDays,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return '📚 Day $dayNumber of $totalDays: "${card.title}" — ${card.description}';
  }
}