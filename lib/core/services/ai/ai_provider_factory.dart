import 'ai_provider.dart';
import 'mock_ai_provider.dart';
import 'gemini_ai_provider.dart';

class AIProviderFactory {
  static AIProvider? _instance;
  
  /// Создать AI провайдер
  /// [type] может быть: 'mock', 'gemini'
  static AIProvider create({String type = 'gemini', String? apiKey}) {
    switch (type) {
      case 'mock':
        return MockAIProvider();
      case 'gemini':
        final key = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');
        if (key.isEmpty) {
          print('⚠️ GEMINI_API_KEY not found, using MockAIProvider');
          return MockAIProvider();
        }
        return GeminiAIProvider(apiKey: key);
      default:
        return MockAIProvider();
    }
  }
  
  /// Получить синглтон провайдера
  static AIProvider get instance {
    _instance ??= create();
    return _instance!;
  }
}