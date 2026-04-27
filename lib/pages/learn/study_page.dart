import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system.dart';  
import '../../core/models/learning_card.dart';
import '../../core/repositories/learning_card_repository.dart';


class StudyPage extends StatefulWidget {
  final List<LearningCardModel> cards;
  final VoidCallback? onBackTap;

  const StudyPage({
    super.key,
    required this.cards,
    this.onBackTap,
  });

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showBack = false;
  
  // Для SRS ответов
  final Set<String> _knownCards = {};
  final Set<String> _unknownCards = {};
  
  // Анимация переворота карточки
  late AnimationController _flipController;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
      _showBack = !_showBack;
    });
    HapticFeedback.lightImpact();
  }

  void _nextCard() {
    if (_currentIndex + 1 < widget.cards.length) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _showBack = false;
        _flipController.reverse();
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
        _showBack = false;
        _flipController.reverse();
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _markAsKnown() {
    final card = widget.cards[_currentIndex];
    if (card.cardType == 'srs') {
      setState(() {
        _knownCards.add(card.id);
      });
    }
    _nextCard();
    HapticFeedback.mediumImpact();
  }

  void _markAsUnknown() {
    final card = widget.cards[_currentIndex];
    if (card.cardType == 'srs') {
      setState(() {
        _unknownCards.add(card.id);
      });
    }
    _nextCard();
    HapticFeedback.mediumImpact();
  }

  void _showCompletionDialog() {
    final knownCount = _knownCards.length;
    final unknownCount = _unknownCards.length;
    final totalReviewed = knownCount + unknownCount;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You reviewed $totalReviewed cards.'),
            const SizedBox(height: 8),
            if (widget.cards.any((c) => c.cardType == 'srs')) ...[
              const Divider(),
              Text('✅ Known: $knownCount'),
              Text('🔄 Review again: $unknownCount'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              widget.onBackTap?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = widget.cards[_currentIndex];
    final isSRS = currentCard.cardType == 'srs';
    final progress = ((_currentIndex + 1) / widget.cards.length) * 100;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
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
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(progress),
                
                // Card Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_currentIndex + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' / ${widget.cards.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF596065),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E9EE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (_currentIndex + 1) / widget.cards.length,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: signatureGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipController,
                        builder: (context, child) {
                          final isFront = !_isFlipped;
                          final angle = _flipController.value * 3.14159;
                          final transform = Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle);
                          
                          return Transform(
                            transform: transform,
                            alignment: Alignment.center,
                            child: isFront
                                ? _buildFrontCard(currentCard)
                                : _buildBackCard(currentCard),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _previousCard,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          side: const BorderSide(color: Color(0xFFACB3B8)),
                        ),
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 20),
                      FilledButton(
                        onPressed: _nextCard,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
                
                // SRS Buttons (only for SRS cards)
                if (isSRS) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _markAsUnknown,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text(
                              'Not Yet',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: _markAsKnown,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Text('Got it'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                widget.onBackTap?.call();
              },
              borderRadius: BorderRadius.circular(28),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Color(0xFF2D3338), size: 24),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Study Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3338),
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildFrontCard(LearningCardModel card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              card.cardType == 'srs' ? 'SRS CARD' : 'FLASHCARD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            card.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Color(0xFF2D3338),
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, size: 16, color: Color(0xFF596065)),
                const SizedBox(width: 8),
                const Text(
                  'Tap to flip',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF596065),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(LearningCardModel card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              card.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: Color(0xFF2D3338),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                card.category,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF596065),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}