import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../design_system.dart';
import '../../core/repositories/learning_card_repository.dart';
import '../../core/models/learning_card.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/ai/ai_provider_factory.dart';
import 'study_page.dart';
import 'folder_screen.dart';

const _uuid = Uuid();

class LearnPage extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const LearnPage({super.key, this.onMenuTap});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final LearningCardRepository _repository = LearningCardRepository();
  final DatabaseService _db = DatabaseService();
  
  bool _showOnHome = true;
  double _notificationFrequency = 4;
  String _activeMainTab = 'Create'; // 'Create' or 'Study'
  String _activeCardType = 'regular'; // 'regular' or 'srs'
  
  // Regular Card Form
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final List<String> _tags = ['Psychology', 'Cognition'];
  final TextEditingController _newTagController = TextEditingController();
  
  int _frontLength = 0;
  int _backLength = 0;
  
  // SRS Card Form
  double _srsCardCount = 10;
  double _srsDuration = 5;
  
  // Created cards list
  List<LearningCardModel> _createdCards = [];
  
  // SRS series check
  bool _hasActiveSRS = false;
  int? _activeSRSRemainingDays;

  @override
  void initState() {
    super.initState();
    _loadCreatedCards();
    _checkActiveSRSSeries();
  }

  Future<void> _loadCreatedCards() async {
    final cards = await _repository.getAllCards();
    setState(() {
      _createdCards = cards;
    });
  }
  
  Future<void> _checkActiveSRSSeries() async {
    final activeSeries = await _db.getActiveSRSSeries();
    if (activeSeries != null) {
      final endDate = DateTime.parse(activeSeries['end_date'] as String);
      final remainingDays = endDate.difference(DateTime.now()).inDays;
      setState(() {
        _hasActiveSRS = true;
        _activeSRSRemainingDays = remainingDays > 0 ? remainingDays : 0;
      });
    } else {
      setState(() {
        _hasActiveSRS = false;
        _activeSRSRemainingDays = null;
      });
    }
  }

  Future<void> _createRegularCard() async {
    if (_frontController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question (front side)')),
      );
      return;
    }
    
    if (_backController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer (back side)')),
      );
      return;
    }
    
    final card = LearningCardModel(
      id: _uuid.v4(),
      title: _frontController.text.trim(),
      description: _backController.text.trim(),
      category: _tags.isNotEmpty ? _tags.first : 'General',
      colorIndex: 0,
      cardType: 'regular',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.saveCard(card);
    
    // ✅ Добавляем карточку в дефолтный сет "All Cards"
    await _db.addCardToSet('set_default', card.id);
    
    setState(() {
      _frontController.clear();
      _backController.clear();
      _frontLength = 0;
      _backLength = 0;
    });
    
    await _loadCreatedCards();
    
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✨ Card created successfully!')),
    );
  }
  
  Future<void> _createSRSSeries() async {
    // Проверка наличия активной SRS серии
    if (_hasActiveSRS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ You already have an active SRS series. ${_activeSRSRemainingDays ?? ""} days remaining.'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (_frontController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question (front side)')),
      );
      return;
    }
    
    if (_backController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an answer (back side)')),
      );
      return;
    }
    
    // Показываем индикатор загрузки для AI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating SRS content...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      // Генерируем уведомления через AI
      final ai = AIProviderFactory.create();
      final now = DateTime.now();
      final endDate = now.add(Duration(days: _srsDuration.toInt()));
      final seriesId = _uuid.v4();
      final cardId = _uuid.v4();
      final notificationCount = _notificationFrequency.toInt();
      
      // Создаём карточку
      final card = LearningCardModel(
        id: cardId,
        title: _frontController.text.trim(),
        description: _backController.text.trim(),
        category: _tags.isNotEmpty ? _tags.first : 'General',
        colorIndex: 0,
        cardType: 'srs',
        srsInterval: _srsDuration.toInt(),
        srsEaseFactor: 2.5,
        srsReviewDate: endDate,
        srsStreak: 0,
        createdAt: now,
        updatedAt: now,
      );
      
      await _repository.saveCard(card);
      
      // ✅ Добавляем карточку в дефолтный сет "All Cards"
      await _db.addCardToSet('set_default', card.id);
      
      // Сохраняем SRS серию
      await _db.insertSRSSeries({
        'id': seriesId,
        'card_id': cardId,
        'start_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'notification_count': notificationCount,
        'notifications_sent': 0,
        'is_active': 1,
      });
      
      // Генерируем уведомления через AI
      final dayInterval = _srsDuration.toInt() ~/ notificationCount;
      
      for (int i = 0; i < notificationCount; i++) {
        final dayNumber = i + 1;
        final scheduledTime = now.add(Duration(days: dayInterval * i));
        
        if (scheduledTime.isAfter(now)) {
          String notificationText;
          try {
            notificationText = await ai.generateNotificationContent(
              card: card,
              dayNumber: dayNumber,
              totalDays: notificationCount,
            );
          } catch (e) {
            // Fallback текст если AI не ответил
            notificationText = '📚 "${card.title}" — ${card.description}';
          }
          
          await _db.insertSRSNotification({
            'id': _uuid.v4(),
            'series_id': seriesId,
            'notification_text': notificationText,
            'scheduled_time': scheduledTime.toIso8601String(),
            'status': 'pending',
          });
        }
      }
      
      Navigator.of(context).pop(); // Закрываем диалог загрузки
      
      setState(() {
        _frontController.clear();
        _backController.clear();
        _frontLength = 0;
        _backLength = 0;
        _hasActiveSRS = true;
        _activeSRSRemainingDays = _srsDuration.toInt();
      });
      
      await _loadCreatedCards();
      await _checkActiveSRSSeries();
      
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎯 SRS Series started! $notificationCount notifications scheduled over ${_srsDuration.toInt()} days.'),
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Отправляем тестовое уведомление
      await NotificationService().showSRSNotification(
        term: card.title,
        definition: card.description,
        dayNumber: 1,
        totalDays: notificationCount,
        context: 'Your SRS learning journey has begun!',
      );
      
    } catch (e) {
      Navigator.of(context).pop(); // Закрываем диалог загрузки при ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating SRS series: $e')),
      );
    }
  }

  void _addTag() {
    if (_newTagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_newTagController.text.trim());
        _newTagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Ambient lighting
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: screenSize.width * 0.6,
              height: screenSize.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.2,
            left: -150,
            child: Container(
              width: screenSize.width * 0.6,
              height: screenSize.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: screenSize.width * 0.1,
            child: Container(
              width: screenSize.width * 0.6,
              height: screenSize.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        _buildSettingsGroup(),
                        const SizedBox(height: 32),
                        _buildMainTabs(),
                        const SizedBox(height: 24),
                        _activeMainTab == 'Create' ? _buildCreateTab() : _buildStudyTab(),
                        const SizedBox(height: 48),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onMenuTap,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.menu, color: AppColors.primary, size: 28),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Learn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: AppColors.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2D3338).withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 20)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/settings_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(color: Colors.white.withOpacity(0.65)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildSettingsRow(),
                  const SizedBox(height: 24),
                  Container(height: 1, color: AppColors.outlineVariant.withOpacity(0.15)),
                  const SizedBox(height: 24),
                  _buildSliderSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Show on Home Page', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              ),
              const SizedBox(height: 4),
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Keep your daily micro-steps visible', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildToggleSwitch(value: _showOnHome, onChanged: (v) => setState(() => _showOnHome = v)),
      ],
    );
  }

  Widget _buildSliderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Frequency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            const SizedBox(height: 4),
            Text('${_notificationFrequency.toInt()} steps scheduled today', style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceContainerHighest,
            thumbColor: AppColors.primary,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            overlayColor: AppColors.primary.withOpacity(0.15),
          ),
          child: Slider(
            value: _notificationFrequency,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => setState(() => _notificationFrequency = v),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Gentle', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
            Text('Focused', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
            Text('Intense', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSwitch({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onChanged(!value); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: value ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: value ? 28 : 4,
              top: 4,
              child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTabs() {
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
            _buildMainTab('Create', _activeMainTab == 'Create'),
            const SizedBox(width: 4),
            _buildMainTab('Study', _activeMainTab == 'Study'),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _activeMainTab = label);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : const Color(0xFF596065),
          ),
        ),
      ),
    );
  }

  // ==================== CREATE TAB ====================
  
  Widget _buildCreateTab() {
    return Column(
      children: [
        // Hero Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mastery.',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -0.5,
                  color: Color(0xFF2D3338),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Refine your knowledge architecture',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF596065),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Card Type Segmented Control
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEEF2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCardTypeTab('Regular', _activeCardType == 'regular'),
                const SizedBox(width: 4),
                _buildCardTypeTab('With SRS', _activeCardType == 'srs'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Regular Card Form
        if (_activeCardType == 'regular') _buildRegularCardForm(),
        
        // SRS Card Form
        if (_activeCardType == 'srs') _buildSRSForm(),
        
        const SizedBox(height: 32),
        
        // Recent Creations
        if (_createdCards.isNotEmpty) _buildRecentCreations(),
      ],
    );
  }

  Widget _buildCardTypeTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _activeCardType = label == 'Regular' ? 'regular' : 'srs');
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : const Color(0xFF596065),
          ),
        ),
      ),
    );
  }

  Widget _buildRegularCardForm() {
    return Column(
      children: [
        // Front Side
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Front Side (Question)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF596065),
                    ),
                  ),
                  Text(
                    '$_frontLength / 280',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFACB3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _frontController,
                maxLines: 5,
                minLines: 4,
                onChanged: (text) {
                  setState(() {
                    _frontLength = text.length;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Type your question here...',
                  hintStyle: const TextStyle(color: Color(0xFFACB3B8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(24),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Back Side
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Back Side (Answer)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF596065),
                    ),
                  ),
                  Text(
                    '$_backLength / 500',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFACB3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _backController,
                maxLines: 5,
                minLines: 4,
                onChanged: (text) {
                  setState(() {
                    _backLength = text.length;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Type the answer here...',
                  hintStyle: const TextStyle(color: Color(0xFFACB3B8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(24),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Category Tags
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Category Tags',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF596065),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3338),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: const Icon(Icons.close, size: 16, color: Color(0xFFACB3B8)),
                      ),
                    ],
                  ),
                )),
                // Add Tag Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showAddTagDialog,
                      borderRadius: BorderRadius.circular(22),
                      child: const Icon(Icons.add, color: AppColors.primary, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        
        // Create Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _createRegularCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 20),
                SizedBox(width: 8),
                Text('Create Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Save as Draft
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Draft saved (coming soon)')),
              );
            },
            child: const Text(
              'Save as Draft',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF596065),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSRSForm() {
    return Column(
      children: [
        // Индикатор активной SRS серии
        if (_hasActiveSRS)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active SRS Series',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${_activeSRSRemainingDays ?? 0} days remaining. Create regular cards until series completes.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF596065),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        // SRS Info Card
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology, size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cognitive Pulse',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3338),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'The Spaced Repetition System (SRS) leverages the forgetting curve to prompt your brain just as the memory begins to fade.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF596065),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Card Count Slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Card Count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF596065),
                  ),
                ),
                Text(
                  '${_srsCardCount.toInt()}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _srsCardCount,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: _hasActiveSRS ? null : (v) => setState(() => _srsCardCount = v),
              activeColor: AppColors.primary,
              inactiveColor: const Color(0xFFDDE3E9),
            ),
            if (_srsCardCount == 10)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    const Text(
                      'Maximum card count for SRS series is 10.',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Duration Slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF596065),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_srsDuration.toInt()}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'days',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF596065),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _srsDuration,
              min: 3,
              max: 7,
              divisions: 4,
              onChanged: _hasActiveSRS ? null : (v) => setState(() => _srsDuration = v),
              activeColor: AppColors.primary,
              inactiveColor: const Color(0xFFDDE3E9),
            ),
          ],
        ),
        const SizedBox(height: 48),
        
        // Visual Anchor
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCen5dA38CqShrSTSbHD9YqUhm4MJX1QDh4LLXF6usqTAHu1YfmBoUMFwj0XlaZ4Rm8TPrYwEcuz9WD_6Cy5aTf5ndJPGAFMoi6F86kYrpSONVyx_lBvaAa05qKNJR5EcH3u9DlIJQfJnAELZL3Kmr74lo9mcAB-3JGrPTwkcAkg5DqvxMmVh3dzoJBDoPm6OBEIU_CVEho-4gSNCm-yKH38PgTXQ2Qz2OpHlBN8Dxg_aW-cZ7OSKv8S5t14uiH2T-E8ZpmEX5WTZly',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALGORITHM READY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Next optimal review scheduled automatically.',
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
        ),
        const SizedBox(height: 40),
        
        // Start Series Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _hasActiveSRS ? null : _createSRSSeries,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 8,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start New Series', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.bolt, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCreations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Recent Creations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3338),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._createdCards.take(3).map((card) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  card.cardType == 'srs' ? Icons.psychology : Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          card.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3338),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (card.cardType == 'srs')
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SRS',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF596065),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  card.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Tag'),
        content: TextField(
          controller: _newTagController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter tag name...',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _addTag();
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ==================== STUDY TAB ====================
  
  Widget _buildStudyTab() {
    if (_createdCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No cards yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3338),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first learning card to start studying',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF596065),
              ),
            ),
          ],
        ),
      );
    }
    
    // ВАЖНО: используем FolderScreen вместо старого списка
    return FolderScreen(onMenuTap: widget.onMenuTap);
  }
}