import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/test_question.dart';
import '../../models/open_question.dart';
import '../../models/learning_card.dart';
import 'ai_provider.dart';
import 'mock_ai_provider.dart';

/// Реальный AI провайдер через Google Gemini
class GeminiAIProvider implements AIProvider {
  late final GenerativeModel _model;
  
  GeminiAIProvider({required String apiKey}) {
    try {
      _model = GenerativeModel(
        model: 'gemini-flash-latest',  // ← правильное название
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topP: 0.95,
          topK: 40,
          maxOutputTokens: 2048,
        ),
      );
      print('✅ Gemini model initialized: gemini-flash-latest');
    } catch (e) {
      print('❌ Failed to initialize Gemini: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<TestQuestion>> generateTestQuestions({
    required List<LearningCardModel> cards,
    required int count,
  }) async {
    if (cards.isEmpty) return [];
    
    final cardsData = cards.map((card) {
      return '- Term: "${card.title}", Definition: "${card.description}", Category: "${card.category}"';
    }).join('\n');
    
    final prompt = '''
You are an expert tutor creating challenging multiple-choice test questions.

Learning cards:
$cardsData

Generate $count test questions. For each question:
1. Create a thoughtful, non-obvious question
2. The correct answer must be EXACTLY the definition from the card
3. Create 3 plausible wrong answers that are related to the concept but incorrect

Return ONLY valid JSON:
[
  {
    "questionText": "...",
    "options": ["correct", "wrong1", "wrong2", "wrong3"],
    "correctOptionIndex": 0,
    "explanation": "Brief explanation"
  }
]
''';
    
    try {
      print('🤖 Calling Gemini API for test questions...');
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      print('📝 Gemini response received, length: ${text.length}');
      
      final jsonString = _extractJson(text);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      final questions = <TestQuestion>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < jsonList.length && i < cards.length; i++) {
        final questionJson = jsonList[i];
        final card = cards[i % cards.length];
        
        questions.add(TestQuestion(
          id: 'gemini_${now}_$i',
          cardId: card.id,
          questionText: questionJson['questionText'] as String,
          options: List<String>.from(questionJson['options'] as List),
          correctOptionIndex: questionJson['correctOptionIndex'] as int,
          explanation: questionJson['explanation'] as String,
          category: card.category,
        ));
      }
      
      print('✅ Generated ${questions.length} test questions');
      return questions;
    } catch (e) {
      print('❌ Gemini API error: $e');
      return MockAIProvider().generateTestQuestions(cards: cards, count: count);
    }
  }
  
  @override
  Future<OpenQuestion> generateOpenQuestion({
    required LearningCardModel card,
  }) async {
    final prompt = '''
Based on this learning card, create ONE open-ended question:

Term: "${card.title}"
Definition: "${card.description}"

Return ONLY valid JSON:
{
  "questionText": "Explain what [term] means in your own words.",
  "expectedKeywords": ["keyword1", "keyword2"],
  "sampleAnswer": "A complete example answer"
}
''';
    
    try {
      print('🤖 Calling Gemini API for open question...');
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      
      final jsonString = _extractJson(text);
      final Map<String, dynamic> questionJson = jsonDecode(jsonString);
      
      return OpenQuestion(
        id: 'gemini_open_${DateTime.now().millisecondsSinceEpoch}',
        cardId: card.id,
        term: card.title,
        questionText: questionJson['questionText'] as String,
        expectedKeywords: List<String>.from(questionJson['expectedKeywords'] as List),
        sampleAnswer: questionJson['sampleAnswer'] as String,
        category: card.category,
      );
    } catch (e) {
      print('❌ Gemini API error: $e');
      return MockAIProvider().generateOpenQuestion(card: card);
    }
  }
  
  @override
  Future<double> evaluateOpenAnswer({
    required OpenQuestion question,
    required String userAnswer,
  }) async {
    if (userAnswer.trim().isEmpty) return 0.0;
    
    final prompt = '''
Rate this answer from 0.0 to 1.0.

Question: ${question.questionText}
Expected keywords: ${question.expectedKeywords.join(', ')}

Student's answer: "$userAnswer"

Return ONLY a number between 0.0 and 1.0.
''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      final score = double.tryParse(text) ?? 0.5;
      return score.clamp(0.0, 1.0);
    } catch (e) {
      print('❌ Gemini API error: $e');
      final lowerAnswer = userAnswer.toLowerCase();
      int matched = 0;
      for (final keyword in question.expectedKeywords) {
        if (lowerAnswer.contains(keyword.toLowerCase())) {
          matched++;
        }
      }
      return matched / question.expectedKeywords.length;
    }
  }
  
  @override
  Future<String> generateNotificationContent({
    required LearningCardModel card,
    required int dayNumber,
    required int totalDays,
  }) async {
    final prompt = '''
Create a short engaging notification (max 150 chars):

Word: "${card.title}"
Definition: "${card.description}"
Day: $dayNumber of $totalDays

Return ONLY the notification text.
''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        return '📚 Day $dayNumber: "${card.title}"';
      }
      return text;
    } catch (e) {
      print('❌ Gemini API error: $e');
      return '📚 Day $dayNumber: "${card.title}"';
    }
  }
  
  String _extractJson(String text) {
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end != -1) {
      return text.substring(start, end + 1);
    }
    
    final startObj = text.indexOf('{');
    final endObj = text.lastIndexOf('}');
    if (startObj != -1 && endObj != -1) {
      return text.substring(startObj, endObj + 1);
    }
    
    return text;
  }
}