import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system.dart';
import '../../core/models/learning_card.dart';

class FlashcardStudyPage extends StatefulWidget {
  final List<LearningCardModel> cards;
  final String setName;

  const FlashcardStudyPage({
    super.key,
    required this.cards,
    required this.setName,
  });

  @override
  State<FlashcardStudyPage> createState() => _FlashcardStudyPageState();
}

class _FlashcardStudyPageState extends State<FlashcardStudyPage> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _knownCount = 0;
  int _unknownCount = 0;

  double get _progress => _currentIndex / widget.cards.length;
  int get _remaining => widget.cards.length - _currentIndex;

  void _flipCard() {
    setState(() => _isFlipped = !_isFlipped);
    HapticFeedback.lightImpact();
  }

  void _markAsKnown() {
    setState(() {
      _knownCount++;
      _nextCard();
    });
    HapticFeedback.mediumImpact();
  }

  void _markAsUnknown() {
    setState(() {
      _unknownCount++;
      _nextCard();
    });
    HapticFeedback.mediumImpact();
  }

  void _nextCard() {
    if (_currentIndex + 1 < widget.cards.length) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You reviewed ${widget.cards.length} cards.'),
            const SizedBox(height: 8),
            Text('✅ Known: $_knownCount'),
            Text('🔄 Review again: $_unknownCount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _knownCount = 0;
                _unknownCount = 0;
                _isFlipped = false;
              });
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('Study Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = widget.cards[_currentIndex];
    final remainingPercent = ((widget.cards.length - _currentIndex) / widget.cards.length * 100).toInt();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildProgressInfo(remainingPercent),
                        const SizedBox(height: 16),
                        _buildProgressBar(),
                        const SizedBox(height: 48),
                        Expanded(
                          child: GestureDetector(
                            onTap: _flipCard,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isFlipped
                                  ? _buildBackCard(currentCard)
                                  : _buildFrontCard(currentCard),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                        const SizedBox(height: 32),
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

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(28),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Color(0xFF2D3338), size: 24),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.setName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3338)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Card ${_currentIndex + 1} of ${widget.cards.length}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF596065)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(int remainingPercent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.setName,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.primary),
        ),
        Text(
          '$remainingPercent% Remaining',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF596065)),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E9EE),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: _progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(LearningCardModel card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'FRONT • TERM',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.primary),
          ),
          const SizedBox(height: 48),
          Text(
            card.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: Color(0xFF2D3338)),
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
              children: const [
                Icon(Icons.touch_app, size: 16, color: Color(0xFF596065)),
                SizedBox(width: 8),
                Text('Tap to flip', style: TextStyle(fontSize: 12, color: Color(0xFF596065))),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE8F5E9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 40, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              card.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, height: 1.4, color: Color(0xFF2D3338)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _markAsUnknown,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('Don\'t know', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.error)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _markAsKnown,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            ),
            child: const Text('Know', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}