import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';
import '../core/animations/ui_animations.dart';
import '../core/repositories/learning_card_repository.dart';
import '../core/services/ai/ai_provider_factory.dart';
import '../core/models/learning_card.dart';
import '../core/models/test_question.dart';
import '../core/models/open_question.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// CheckPage — проверка знаний через ИИ на основе карточек пользователя
class CheckPage extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const CheckPage({super.key, this.onMenuTap});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> with TickerProviderStateMixin {
  final LearningCardRepository _repository = LearningCardRepository();
  
  // Состояния для переключателей
  bool _notificationsEnabled = true;
  bool _showOnHome = false;
  
  // Текущая вкладка: 0 = Tests, 1 = Open Questions
  int _currentTab = 0;
  
  // Состояние загрузки
  bool _isLoading = false;
  String? _errorMessage;
  
  // Данные из БД
  List<LearningCardModel> _allCards = [];
  List<LearningCardModel> _cardsForTest = [];
  
  // Реальные данные (заменяют заглушки)
  List<TestQuestion> _testQuestions = [];
  List<OpenQuestion> _openQuestions = [];
  
  // Состояние текущего вопроса
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  String _openAnswer = '';
  bool _isOpenAnswerChecked = false;
  double _openAnswerScore = 0.0;
  
  // Статистика
  int _correctAnswers = 0;
  
  // Анимации
  late AnimationController _tabAnimationController;
  late Animation<double> _tabFadeAnimation;
  late AnimationController _questionAnimationController;
  late Animation<double> _questionAnimation;
  
  // Hover состояния
  bool _isHoveringTestButton = false;
  bool _isHoveringOpenButton = false;
  
  @override
  void initState() {
    super.initState();
    
    _tabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tabFadeAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    );
    
    _questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _questionAnimation = CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeOutCubic,
    );
    _questionAnimationController.forward();
    _tabAnimationController.forward();
    
    _loadCards();
  }
  
  @override
  void dispose() {
    _tabAnimationController.dispose();
    _questionAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      _allCards = await _repository.getAllCards();
      
      // Фильтруем regular карточки для тестов
      _cardsForTest = _allCards.where((c) => c.cardType == 'regular').toList();
      
      if (_cardsForTest.isEmpty && _allCards.isNotEmpty) {
        _cardsForTest = _allCards;
      }
      
      if (_cardsForTest.isNotEmpty) {
        await _generateQuestions();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cards: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generateQuestions() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    // 🔥 ВАЖНО: загружаем ключ из dotenv
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    final ai = AIProviderFactory.create(
      type: apiKey != null && apiKey.isNotEmpty ? 'gemini' : 'mock',
      apiKey: apiKey,  // ← передаём ключ!
    );
    
    // Генерируем тесты
    _testQuestions = await ai.generateTestQuestions(
      cards: _cardsForTest,
      count: _cardsForTest.length > 3 ? 3 : _cardsForTest.length,
    );
    
    // Генерируем открытые вопросы
    _openQuestions = [];
    final openCount = _cardsForTest.length > 3 ? 3 : _cardsForTest.length;
    for (int i = 0; i < openCount; i++) {
      final openQuestion = await ai.generateOpenQuestion(card: _cardsForTest[i]);
      _openQuestions.add(openQuestion);
    }
    
    _resetSession();
    
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to generate questions: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
      _questionAnimationController.forward();
    });
  }
}
  
  void _resetSession() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _isAnswerChecked = false;
      _openAnswer = '';
      _isOpenAnswerChecked = false;
      _openAnswerScore = 0.0;
      _correctAnswers = 0;
    });
  }
  
  void _switchTab(int index) {
    if (_currentTab == index) return;
    
    setState(() {
      _currentTab = index;
      _currentQuestionIndex = 0;
      _resetSession();
      _questionAnimationController.reset();
      _questionAnimationController.forward();
    });
    HapticFeedback.lightImpact();
    
    _tabAnimationController.reset();
    _tabAnimationController.forward();
  }
  
  void _resetForNextQuestion() {
    setState(() {
      _selectedOptionIndex = null;
      _isAnswerChecked = false;
      _openAnswer = '';
      _isOpenAnswerChecked = false;
      _openAnswerScore = 0.0;
      _questionAnimationController.reset();
      _questionAnimationController.forward();
    });
  }
  
  void _nextQuestion() {
    HapticFeedback.lightImpact();
    
    if (_currentQuestionIndex + 1 < (_currentTab == 0 ? _testQuestions.length : _openQuestions.length)) {
      setState(() {
        _currentQuestionIndex++;
        _resetForNextQuestion();
      });
    } else {
      _showCompletionDialog();
    }
  }
  
  void _showCompletionDialog() {
    final total = _currentTab == 0 ? _testQuestions.length : _openQuestions.length;
    final score = _currentTab == 0 
        ? (_correctAnswers / total * 100).toInt()
        : (_openAnswerScore * 100).toInt();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You completed $total questions.'),
            const SizedBox(height: 8),
            Text(
              'Your score: $score%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: score >= 70 ? AppColors.primary : AppColors.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _generateQuestions();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('New Session'),
          ),
        ],
      ),
    );
  }
  
  void _checkAnswer() {
    if (_selectedOptionIndex == null) return;
    
    final isCorrect = _selectedOptionIndex == _testQuestions[_currentQuestionIndex].correctOptionIndex;
    
    setState(() {
      _isAnswerChecked = true;
      if (isCorrect) _correctAnswers++;
    });
    HapticFeedback.mediumImpact();
  }
  
  Future<void> _checkOpenAnswer() async {
    if (_openAnswer.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final ai = AIProviderFactory.create();
      final score = await ai.evaluateOpenAnswer(
        question: _openQuestions[_currentQuestionIndex],
        userAnswer: _openAnswer,
      );
      
      setState(() {
        _openAnswerScore = score;
        _isOpenAnswerChecked = true;
      });
    } catch (e) {
      print('Error evaluating answer: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    
    HapticFeedback.mediumImpact();
  }
  
  int _getProgress() => _currentQuestionIndex + 1;
  int _getTotal() => _currentTab == 0 ? _testQuestions.length : _openQuestions.length;
  double _getProgressPercent() => _getProgress() / _getTotal();
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 700;
    
    // Проверка на ошибку загрузки
    if (_errorMessage != null) {
      return Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFF596065)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _loadCards,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Проверка на отсутствие карточек
    if (!_isLoading && _allCards.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, size: 60, color: AppColors.primary),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Cards Yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3338),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create learning cards in Learn → Create to start testing',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF596065),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _loadCards,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Состояние загрузки
    if (_isLoading || (_testQuestions.isEmpty && _openQuestions.isEmpty)) {
      return Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopAppBar(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            _allCards.isEmpty ? 'Loading cards...' : 'AI is generating questions...',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF596065),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    final currentTest = _testQuestions.isNotEmpty && _currentTab == 0
        ? _testQuestions[_currentQuestionIndex]
        : null;
    final currentOpen = _openQuestions.isNotEmpty && _currentTab == 1
        ? _openQuestions[_currentQuestionIndex]
        : null;
    
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 16),
                    child: Column(
                      children: [
                        _buildSettingsCard(),
                        const SizedBox(height: 24),
                        _buildTabs(isDesktop),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _tabFadeAnimation,
                          child: AnimatedBuilder(
                            animation: _questionAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _questionAnimation.value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - _questionAnimation.value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _currentTab == 0 && currentTest != null
                                ? _buildTestsTab(currentTest, isDesktop)
                                : _currentTab == 1 && currentOpen != null
                                    ? _buildOpenQuestionsTab(currentOpen, isDesktop)
                                    : const SizedBox(),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackground() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _questionAnimationController,
          builder: (context, child) {
            final value = _questionAnimationController.value;
            return Positioned(
              top: -100 + value * 20,
              right: -100 + value * 10,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.05 + value * 0.03),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onMenuTap,
              borderRadius: BorderRadius.circular(28),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.menu, color: AppColors.primary, size: 24),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Check Knowledge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3338),
                ),
              ),
            ),
          ),
          PulsingAnimation(
            duration: const Duration(seconds: 3),
            minScale: 0.98,
            maxScale: 1.02,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE4E9EE),
              ),
              child: const Icon(Icons.person, color: Color(0xFF596065), size: 20),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBVG9lHfWpG6Aofbol_Fz7t5ZUH8vWyituVsqPGIBmDaC6L3s574M8ajmTN3Ng9_WOLJ5kFZ-WcVO1_Ivh49X4pgchOoLZEbKFnR26y8VNuukDUcJi2fxxSaTchxWeL2UfvUdNTKNZxdf8ENK18DNtACDK8B1-Scs0bOFuhubgB_5afVjjggkI8lYfJVOFT-bdXsYqF6_w2zYDWi5pWBYw6Hf-L5r9qJXJaRi428I6VoAauEzGtV7H1Kiv4FCThwTsRQjV4Aee0UeLv',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.85)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 500;
                  
                  if (isDesktop) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSettingRow(
                            title: 'Notification Frequency',
                            subtitle: 'Daily review reminders',
                            value: _notificationsEnabled,
                            onChanged: (v) => setState(() => _notificationsEnabled = v),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: const Color(0xFFACB3B8).withOpacity(0.2),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        Expanded(
                          child: _buildSettingRow(
                            title: 'Show on Home Page',
                            subtitle: 'Pinned learning goals',
                            value: _showOnHome,
                            onChanged: (v) => setState(() => _showOnHome = v),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildSettingRow(
                          title: 'Notification Frequency',
                          subtitle: 'Daily review reminders',
                          value: _notificationsEnabled,
                          onChanged: (v) => setState(() => _notificationsEnabled = v),
                        ),
                        const SizedBox(height: 24),
                        _buildSettingRow(
                          title: 'Show on Home Page',
                          subtitle: 'Pinned learning goals',
                          value: _showOnHome,
                          onChanged: (v) => setState(() => _showOnHome = v),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3338),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF596065),
                ),
              ),
            ],
          ),
        ),
        AnimatedCheckbox(
          value: value,
          onChanged: onChanged,
          size: 24,
        ),
      ],
    );
  }
  
  Widget _buildTabs(bool isDesktop) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEEF2),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabButton('Tests', 0, isDesktop),
            const SizedBox(width: 4),
            _buildTabButton('Open Questions', 1, isDesktop),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabButton(String label, int index, bool isDesktop) {
    final isActive = _currentTab == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() {
        if (index == 0) _isHoveringTestButton = true;
        else _isHoveringOpenButton = true;
      }),
      onExit: (_) => setState(() {
        if (index == 0) _isHoveringTestButton = false;
        else _isHoveringOpenButton = false;
      }),
      child: GestureDetector(
        onTap: () => _switchTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index == 0 && _isHoveringTestButton && !isActive)
                const Icon(Icons.quiz, size: 18, color: AppColors.primary),
              if (index == 0 && isActive)
                const Icon(Icons.quiz, size: 18, color: AppColors.primary),
              if (index == 0 && (!_isHoveringTestButton && !isActive))
                const SizedBox(width: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : const Color(0xFF596065),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ==================== TESTS TAB ====================
  
  Widget _buildTestsTab(TestQuestion question, bool isDesktop) {
    final isCorrect = _isAnswerChecked && _selectedOptionIndex == question.correctOptionIndex;
    final isWrong = _isAnswerChecked && _selectedOptionIndex != null && _selectedOptionIndex != question.correctOptionIndex;
    
    return Column(
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlowOnHover(
              glowIntensity: 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'AI-powered session',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              '${_getProgress()} of ${_getTotal()} cards',
              style: const TextStyle(fontSize: 14, color: Color(0xFF596065)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Animated Progress bar
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: _getProgressPercent()),
          builder: (context, value, child) {
            return Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E9EE),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: signatureGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        
        // Question Card
        GlowOnHover(
          glowIntensity: 0.08,
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 48 : 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'TERM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                    color: Color(0xFF2D3338),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8FCEA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question.category ?? 'General',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF315043),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Options
        ...List.generate(question.options.length, (index) {
          final option = question.options[index];
          final letter = String.fromCharCode(65 + index);
          final isSelected = _selectedOptionIndex == index;
          final showCorrect = _isAnswerChecked && index == question.correctOptionIndex;
          final showWrong = _isAnswerChecked && isSelected && !showCorrect;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: _isAnswerChecked ? null : () {
                setState(() {
                  _selectedOptionIndex = index;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: showCorrect
                      ? AppColors.primaryContainer.withOpacity(0.3)
                      : showWrong
                          ? AppColors.errorContainer.withOpacity(0.15)
                          : isSelected
                              ? AppColors.primary.withOpacity(0.08)
                              : const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: showCorrect
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : showWrong
                          ? Border.all(color: AppColors.error, width: 1.5)
                          : isSelected
                              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
                              : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: showCorrect || showWrong
                            ? Colors.transparent
                            : isSelected
                                ? AppColors.primary
                                : const Color(0xFFE4E9EE),
                        shape: BoxShape.circle,
                        border: showCorrect || showWrong
                            ? Border.all(
                                color: showCorrect ? AppColors.primary : AppColors.error,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: showCorrect || showWrong
                                ? (showCorrect ? AppColors.primary : AppColors.error)
                                : isSelected
                                    ? Colors.white
                                    : const Color(0xFF596065),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          color: showCorrect || showWrong
                              ? (showCorrect ? AppColors.primary : AppColors.error)
                              : const Color(0xFF2D3338),
                          decoration: showWrong ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (showCorrect)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                    if (showWrong)
                      const Icon(Icons.cancel, color: AppColors.error, size: 24),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
        
        // Explanation (if checked)
        if (_isAnswerChecked)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedOptionIndex == question.correctOptionIndex
                        ? Icons.emoji_events
                        : Icons.psychology,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF2D3338),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isAnswerChecked)
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedOptionIndex != null ? _checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    disabledBackgroundColor: const Color(0xFFE4E9EE),
                    disabledForegroundColor: const Color(0xFF596065),
                  ),
                  child: const Text('Check Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            if (_isAnswerChecked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOptionIndex = null;
                        _isAnswerChecked = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      side: const BorderSide(color: Color(0xFFACB3B8)),
                    ),
                    child: const Text('Study again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _nextQuestion,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text('Got it', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
  
  // ==================== OPEN QUESTIONS TAB ====================
  
  Widget _buildOpenQuestionsTab(OpenQuestion question, bool isDesktop) {
    final isCorrect = _isOpenAnswerChecked && _openAnswerScore >= 0.7;
    
    return Column(
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlowOnHover(
              glowIntensity: 0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'AI-powered session',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              '${_getProgress()} of ${_getTotal()} cards',
              style: const TextStyle(fontSize: 14, color: Color(0xFF596065)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Animated Progress bar
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: _getProgressPercent()),
          builder: (context, value, child) {
            return Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E9EE),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: signatureGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        
        // Question Card
        GlowOnHover(
          glowIntensity: 0.08,
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 48 : 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'TERM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                    color: Color(0xFF2D3338),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Input field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your definition or explanation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF596065),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => _openAnswer = value,
              enabled: !_isOpenAnswerChecked,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: const TextStyle(color: Color(0xFFACB3B8)),
                filled: true,
                fillColor: const Color(0xFFF2F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.edit_note, color: Color(0xFFACB3B8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Explanation (if checked)
        if (_isOpenAnswerChecked)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.psychology,
                        color: isCorrect ? AppColors.primary : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isCorrect ? 'Great Answer!' : 'Sample Answer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCorrect ? AppColors.primary : Color(0xFF2D3338),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.sampleAnswer,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF2D3338),
                    ),
                  ),
                  if (!isCorrect && _openAnswerScore > 0) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _openAnswerScore,
                      backgroundColor: const Color(0xFFE4E9EE),
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your answer scored ${(_openAnswerScore * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF596065),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isOpenAnswerChecked)
              Expanded(
                child: ElevatedButton(
                  onPressed: _openAnswer.trim().isNotEmpty ? _checkOpenAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    disabledBackgroundColor: const Color(0xFFE4E9EE),
                    disabledForegroundColor: const Color(0xFF596065),
                  ),
                  child: const Text('Check Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            if (_isOpenAnswerChecked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _openAnswer = '';
                        _isOpenAnswerChecked = false;
                        _openAnswerScore = 0.0;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      side: const BorderSide(color: Color(0xFFACB3B8)),
                    ),
                    child: const Text('Study again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _nextQuestion,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text('Got it', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}