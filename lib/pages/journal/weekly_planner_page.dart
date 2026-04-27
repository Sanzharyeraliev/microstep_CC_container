import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../design_system.dart';
/// WeeklyPlannerPage — точная копия HTML дизайна
class WeeklyPlannerPage extends StatefulWidget {
  final VoidCallback? onBackTap;

  const WeeklyPlannerPage({super.key, this.onBackTap});

  @override
  State<WeeklyPlannerPage> createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  // Данные для каждого дня недели
  final Map<String, DayData> _weekData = {
    'Monday': DayData(
      dayName: 'Mon',
      fullName: 'Monday',
      date: 12,
      tasks: [
        TaskItem(title: 'Review product roadmap', completed: false),
        TaskItem(title: 'Morning meditation', completed: true),
      ],
      isToday: false,
      imagePath: 'assets/images/monday_weekly_planner.png',
    ),
    'Tuesday': DayData(
      dayName: 'Tue',
      fullName: 'Tuesday',
      date: 13,
      tasks: [
        TaskItem(title: 'Design system audit', completed: false),
      ],
      isToday: false,
      imagePath: 'assets/images/tuesday_weekly_planner.png',
    ),
    'Wednesday': DayData(
      dayName: 'Wed',
      fullName: 'Wednesday',
      date: 14,
      tasks: [
        TaskItem(title: 'Client presentation', completed: false),
        TaskItem(title: 'Team sync at 2PM', completed: false),
        TaskItem(title: 'Update case study', completed: false),
      ],
      isToday: true,
      imagePath: 'assets/images/wednesday_weekly_planner.png',
    ),
    'Thursday': DayData(
      dayName: 'Thu',
      fullName: 'Thursday',
      date: 15,
      tasks: [],
      isToday: false,
      imagePath: 'assets/images/thursday_weekly_planner.png',
    ),
    'Friday': DayData(
      dayName: 'Fri',
      fullName: 'Friday',
      date: 16,
      tasks: [
        TaskItem(title: 'Weekly retrospective', completed: false),
      ],
      isToday: false,
      imagePath: 'assets/images/friday_weekly_planner.png',
    ),
    'Saturday': DayData(
      dayName: 'Sat',
      fullName: 'Saturday',
      date: 17,
      tasks: [
        TaskItem(title: 'Read 50 pages', completed: false),
      ],
      isToday: false,
      imagePath: 'assets/images/saturday_weekly_planner.png',
    ),
    'Sunday': DayData(
      dayName: 'Sun',
      fullName: 'Sunday',
      date: 18,
      tasks: [
        TaskItem(title: 'Plan next week', completed: false),
      ],
      isToday: false,
      imagePath: 'assets/images/sunday_weekly_planner.png',
    ),
  };

  int _totalTasksCompleted = 12;
  String _mostProductiveDay = 'Tuesday';
  double _focusHours = 18;
  double _deepSprints = 4;
  double _growthPace = 64;

  void _toggleTaskCompletion(String dayKey, int taskIndex) {
    setState(() {
      final task = _weekData[dayKey]!.tasks[taskIndex];
      task.completed = !task.completed;
      _recalculateStats();
    });
    HapticFeedback.lightImpact();
  }

  void _recalculateStats() {
    int completed = 0;
    for (final day in _weekData.values) {
      for (final task in day.tasks) {
        if (task.completed) completed++;
      }
    }
    setState(() {
      _totalTasksCompleted = completed;
    });
  }

  void _showAddTaskDialog(String dayKey) {
    final controller = TextEditingController();
    bool hasText = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add Task for ${_weekData[dayKey]!.dayName}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3338),
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            onChanged: (text) {
              setDialogState(() => hasText = text.trim().isNotEmpty);
            },
            decoration: const InputDecoration(
              hintText: 'e.g., Complete project review',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: hasText
                  ? () {
                      setState(() {
                        _weekData[dayKey]!.tasks.add(
                          TaskItem(title: controller.text.trim(), completed: false),
                        );
                        _recalculateStats();
                      });
                      Navigator.of(ctx).pop();
                      HapticFeedback.mediumImpact();
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decoration
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
          Positioned(
            bottom: -100,
            right: 50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        _buildGrowthSection(),
                        const SizedBox(height: 48),
                        _buildWeeklyGrid(),
                        const SizedBox(height: 96),
                        _buildProductivitySummary(),
                        const SizedBox(height: 120),
                      ],
                    ).animate().slideY(
                          duration: 600.ms,
                          begin: 0.1,
                          curve: Curves.easeOutCubic,
                        ).fadeIn(
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Action Button
          Positioned(
            right: 32,
            bottom: 100,
            child: GestureDetector(
              onTap: () {
                final todayKey = _weekData.keys.firstWhere(
                  (key) => _weekData[key]!.isToday,
                  orElse: () => 'Wednesday',
                );
                _showAddTaskDialog(todayKey);
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: signatureGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ).animate(delay: 400.ms).scale(
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                    widget.onBackTap?.call();
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF064E3B),
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Weekly Planner',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF064E3B),
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE4E9EE),
            ),
            child: const Icon(Icons.person, color: Color(0xFF596065)),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;
        
        if (isDesktop) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Momentum',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: Color(0xFF2D3338),
                        ),
                        children: const [
                          TextSpan(text: 'Small steps, '),
                          TextSpan(
                            text: 'deep growth.',
                            style: TextStyle(color: Color(0xFF006D42)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your journey this week is a series of intentional breaths. Focus on the progress, not the peak.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Color(0xFF596065),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildGrowthPaceCard(),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Momentum',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Color(0xFF2D3338),
                  ),
                  children: const [
                    TextSpan(text: 'Small steps,\n'),
                    TextSpan(
                      text: 'deep growth.',
                      style: TextStyle(color: Color(0xFF006D42)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your journey this week is a series of intentional breaths.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF596065),
                ),
              ),
              const SizedBox(height: 24),
              _buildGrowthPaceCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildGrowthPaceCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.eco,
            size: 48,
            color: Color(0xFF006D42),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_growthPace.toInt()}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF006D42),
                ),
              ),
              const Text(
                'Growth Pace',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: Color(0xFF596065),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrid() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: days.map((day) => Expanded(child: _buildDayCard(day))).toList().animate(interval: 100.ms).slideX(
                  begin: -0.1,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ).fadeIn(
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
          );
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: days.map((day) => SizedBox(width: 280, child: _buildDayCard(day))).toList().animate(interval: 100.ms).slideX(
                    begin: -0.1,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ).fadeIn(
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDayCard(String dayKey) {
    final day = _weekData[dayKey]!;
    final isToday = day.isToday;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
        border: isToday ? Border.all(color: AppColors.primary.withOpacity(0.05)) : null,
      ),
      child: Stack(
        children: [
          // Локальное фоновое изображение
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  day.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          // Backlight glow for today
          if (isToday)
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: isToday ? AppColors.primary : const Color(0xFF596065),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.date}',
                          style: TextStyle(
                            fontSize: isToday ? 28 : 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3338),
                          ),
                        ),
                      ],
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ...day.tasks.map((task) => _buildTaskItem(dayKey, task)),
                if (day.tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No tasks planned',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF596065),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showAddTaskDialog(dayKey),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Add Task',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String dayKey, TaskItem task) {
    final isCompleted = task.completed;
    final taskIndex = _weekData[dayKey]!.tasks.indexOf(task);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _toggleTaskCompletion(dayKey, taskIndex),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.primary : AppColors.primaryContainer,
                  width: 2,
                ),
                color: isCompleted ? AppColors.primary : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 14,
                color: isCompleted ? const Color(0xFF596065) : const Color(0xFF2D3338),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivitySummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: _buildBloomingCircle(),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 7,
                child: _buildStatsSection(),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildBloomingCircle(),
              const SizedBox(height: 48),
              _buildStatsSection(),
            ],
          );
        }
      },
    );
  }

  Widget _buildBloomingCircle() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryContainer.withOpacity(0.4), width: 2),
        ),
        child: Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.eco,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Blooming',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3338),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your focus is sharper\nthan last week.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF596065),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The Weekly Pulse',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: Color(0xFF064E3B),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF596065),
            ),
            children: [
              TextSpan(text: "You've completed $_totalTasksCompleted tasks this week. Your most productive day was "),
              TextSpan(
                text: _mostProductiveDay,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(text: '. Keep this gentle rhythm going.'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_focusHours.toInt()}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3338),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Focus Hours',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: Color(0xFF596065),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E9EE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _focusHours / 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_deepSprints.toInt()}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3338),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Deep Sprints',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: Color(0xFF596065),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E9EE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _deepSprints / 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Вспомогательные классы
class TaskItem {
  final String title;
  bool completed;
  
  TaskItem({required this.title, required this.completed});
}

class DayData {
  final String dayName;
  final String fullName;
  final int date;
  final List<TaskItem> tasks;
  final bool isToday;
  final String imagePath;
  
  DayData({
    required this.dayName,
    required this.fullName,
    required this.date,
    required this.tasks,
    required this.isToday,
    required this.imagePath,
  });
}