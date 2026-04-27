import 'package:flutter/material.dart';
import '../../design_system.dart';
import '../../core/services/database_service.dart';
import '../../core/models/learning_card.dart';
import 'flashcard_study_page.dart';

class SetScreen extends StatefulWidget {
  final String folderId;
  final String folderName;

  const SetScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<SetScreen> createState() => _SetScreenState();
}

class _SetScreenState extends State<SetScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _sets = [];
  bool _isLoading = true;
  String? _hoveredSetId;

  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  Future<void> _loadSets() async {
    setState(() => _isLoading = true);
    final sets = await _db.getSetsByFolder(widget.folderId);
    setState(() {
      _sets = sets;
      _isLoading = false;
    });
  }

  Future<void> _openSet(Map<String, dynamic> set) async {
    final cardsData = await _db.getCardsBySetId(set['id']);
    final cards = cardsData.map((c) => LearningCardModel.fromMap(c)).toList();
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cards in this set yet. Create some cards first!')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardStudyPage(
          cards: cards,
          setName: set['title'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCards = 0;
    for (final set in _sets) {
      final ids = (set['card_ids'] as String).split(',');
      if (ids.isNotEmpty && ids[0].isNotEmpty) totalCards += ids.length;
    }
    final folderProgress = totalCards > 0 ? 0.0 : 0.0; // можно вычислить позже

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
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildHeader(folderProgress, totalCards),
                          const SizedBox(height: 24),
                          const Text(
                            'Sets',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3338)),
                          ),
                          const SizedBox(height: 16),
                          ..._sets.map((set) => _buildSetCard(set)),
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

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(28),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Sets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3338)),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(double progress, int totalCards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.folderName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.folderName,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Color(0xFF2D3338)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E9EE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}% Mastered',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_sets.length} sets • $totalCards cards',
                style: const TextStyle(fontSize: 12, color: Color(0xFF596065)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSetCard(Map<String, dynamic> set) {
    final cardIdsStr = set['card_ids'] as String;
    final cardCount = cardIdsStr.isEmpty ? 0 : cardIdsStr.split(',').length;
    final isHovered = _hoveredSetId == set['id'];

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSetId = set['id']),
      onExit: (_) => setState(() => _hoveredSetId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -2 : 0),
        margin: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => _openSet(set),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isHovered ? 0.06 : 0.03),
                  blurRadius: isHovered ? 16 : 8,
                  offset: Offset(0, isHovered ? 6 : 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_stories, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            set['title'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3338)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$cardCount terms',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF596065)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.play_arrow, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E9EE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 0.0, // можно добавить логику прогресса
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '0%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}