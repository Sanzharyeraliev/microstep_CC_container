import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system.dart';
import 'weekly_planner_page.dart';

/// JournalPage — новый дизайн на основе HTML
/// Hero Greeting + Settings + Personal Journal + To-Do List + Calendar + Reminders
class JournalPage extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const JournalPage({super.key, this.onMenuTap});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  bool _notificationsEnabled = true;
  bool _homeVisibility = false;
  
  // Calendar state
  DateTime _calendarDate = DateTime.now();
  DateTime? _selectedDate;
  
  // To-Do List state
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'task_1',
      'title': 'Morning Breathwork',
      'subtitle': '10 minutes of deep rhythmic breathing',
      'completed': true,
    },
    {
      'id': 'task_2',
      'title': 'Document Reflections',
      'subtitle': 'Write three things I am grateful for',
      'completed': false,
    },
    {
      'id': 'task_3',
      'title': 'Digital Sunset',
      'subtitle': 'No screens after 9:00 PM',
      'completed': false,
    },
  ];
  
  // Reminders state
  final List<Map<String, dynamic>> _reminders = [
    {
      'id': 'reminder_1',
      'title': 'Read for 20 minutes',
      'completed': false,
    },
    {
      'id': 'reminder_2',
      'title': 'Drink 3L of water',
      'completed': true,
    },
    {
      'id': 'reminder_3',
      'title': 'Mindful breathing session',
      'completed': false,
    },
  ];
  
  // Upcoming events
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Evening Reflection',
      'time': '8:00 PM • Daily',
      'color': 'primary',
    },
    {
      'title': 'Weekly Review',
      'time': 'Oct 20 • 10:00 AM',
      'color': 'tertiary',
    },
  ];
  
  int _taskCounter = 3;
  int _reminderCounter = 3;

  List<Map<String, dynamic>> get _sortedTasks {
    final completed = _tasks.where((t) => t['completed'] == true).toList();
    final uncompleted = _tasks.where((t) => t['completed'] != true).toList();
    return [...completed, ...uncompleted];
  }

  List<Map<String, dynamic>> get _sortedReminders {
    final completed = _reminders.where((r) => r['completed'] == true).toList();
    final uncompleted = _reminders.where((r) => r['completed'] != true).toList();
    return [...uncompleted, ...completed];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decorative glow (как в HTML)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 256,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        // Hero Greeting
                        _buildHeroGreeting(),
                        const SizedBox(height: 48),
                        
                        // Asymmetric Grid Layout
                        _buildAsymmetricGrid(),
                        
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
                child: Icon(
                  Icons.menu,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Journal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // Spacer for symmetry
        ],
      ),
    );
  }

  Widget _buildHeroGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hello, Breathe.',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w200,
            letterSpacing: -0.5,
            color: Color(0xFF2D3338),
            height: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Take a moment to center yourself and capture the essence of your day.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF596065),
          ),
        ),
      ],
    );
  }

  Widget _buildAsymmetricGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 900;
        
        if (isLargeScreen) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildLeftColumn(),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 5,
                child: _buildRightColumn(),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildLeftColumn(),
              const SizedBox(height: 40),
              _buildRightColumn(),
            ],
          );
        }
      },
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settings Section
        _buildSettingsSection(),
        const SizedBox(height: 48),
        
        // Personal Journal Section
        _buildPersonalJournalSection(),
        const SizedBox(height: 48),
        
        // To-Do List Section (восстановлен!)
        _buildToDoListSection(),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event Calendar Section
        _buildEventCalendarSection(),
        const SizedBox(height: 48),
        
        // Reminders Section
        _buildRemindersSection(),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF2D3338),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Notifications Toggle
              _buildSettingToggle(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Stay mindful with gentle nudges',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              // Home Page Visibility Toggle
              _buildSettingToggle(
                icon: Icons.visibility,
                title: 'Home Page Visibility',
                subtitle: 'Keep your inner thoughts private',
                value: _homeVisibility,
                onChanged: (v) => setState(() => _homeVisibility = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3338),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF596065),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFE4E9EE),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 28 : 4,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalJournalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Personal Journal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Color(0xFF2D3338),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Journal Card
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showJournalDialog();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative icon
                Positioned(
                  top: 32,
                  right: 32,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Text(
                          'DAILY PROMPT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Color(0xFF005E39),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'How was your day? Write the one thing that made you smile.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3338),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: signatureGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_note,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Start writing...',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF596065),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ВОССТАНОВЛЕННЫЙ To-Do List
  Widget _buildToDoListSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'To-Do List',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF596065),
            letterSpacing: 3.2,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'Flow of the Day',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2D3338),
            height: 1.25,
          ),
        ),
      ),
      const SizedBox(height: 32),
      // Add Task Input
      _buildAddTaskInput(),
      const SizedBox(height: 24),
      // Task Cards (staggered)
      ...List.generate(_sortedTasks.length, (i) => _buildTaskCard(i)),
      const SizedBox(height: 24),
      // Кнопка Weekly Planner
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WeeklyPlannerPage(
                  onBackTap: () {},
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: signatureGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_view_week,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Plan Your Week',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildAddTaskInput() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAddTaskDialog,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: signatureGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Add a new task...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF596065),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(int index) {
    final tasks = _sortedTasks;
    final task = tasks[index];
    final isCompleted = task['completed'] as bool;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: isCompleted
          ? const EdgeInsets.only(right: 48)
          : const EdgeInsets.only(left: 48),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              task['completed'] = !isCompleted;
            });
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFF2F4F6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isCompleted
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      width: 2,
                    ),
                    color: isCompleted
                        ? Colors.white
                        : const Color(0xFFF2F4F6),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D3338),
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if ((task['subtitle'] as String).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF596065),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    bool hasText = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'New Task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3338),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  onChanged: (text) {
                    setDialogState(() => hasText = text.trim().isNotEmpty);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Task name *',
                    hintText: 'e.g. Morning Breathwork',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g. 10 minutes of deep breathing',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
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
                        _taskCounter++;
                        _tasks.add({
                          'id': 'task_$_taskCounter',
                          'title': titleController.text.trim(),
                          'subtitle': descController.text.trim(),
                          'completed': false,
                        });
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

  void _showJournalDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Journal Entry',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3338),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write your thoughts here...',
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
            onPressed: () {
              // TODO: Save journal entry
              Navigator.of(ctx).pop();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal entry saved!')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCalendarSection() {
    final year = _calendarDate.year;
    final month = _calendarDate.month;
    final today = DateTime.now();
    
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final currentWeek = _getCurrentWeekDays();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Event Calendar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF2D3338),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEEF2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Calendar header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${monthNames[month]} $year',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3338),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Weekly Focus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: Color(0xFF596065),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildCalendarNav(
                        icon: Icons.chevron_left,
                        onTap: () => setState(() {
                          _calendarDate = DateTime(year, month - 1);
                        }),
                      ),
                      const SizedBox(width: 8),
                      _buildCalendarNav(
                        icon: Icons.chevron_right,
                        onTap: () => setState(() {
                          _calendarDate = DateTime(year, month + 1);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Calendar week view
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: currentWeek.map((day) {
                  final isToday = day.day == today.day && 
                                  day.month == today.month && 
                                  day.year == today.year;
                  final isSelected = _selectedDate != null &&
                                     day.day == _selectedDate!.day &&
                                     day.month == _selectedDate!.month;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = day;
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: Column(
                        children: [
                          Text(
                            _getWeekdayLetter(day.weekday),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isToday ? AppColors.primary : const Color(0xFF596065),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isToday ? signatureGradient : null,
                              color: isSelected && !isToday 
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isToday 
                                      ? Colors.white
                                      : const Color(0xFF2D3338),
                                ),
                              ),
                            ),
                          ),
                          if (day.day == 20 && !isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Upcoming events
              ..._upcomingEvents.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 40,
                        decoration: BoxDecoration(
                          color: event['color'] == 'primary' 
                              ? AppColors.primaryContainer
                              : const Color(0xFFD8FCEA),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3338),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event['time'],
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
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Reminders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF2D3338),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ..._sortedReminders.map((reminder) => _buildReminderItem(reminder)),
        const SizedBox(height: 16),
        // Add reminder button
        _buildAddReminderButton(),
      ],
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> reminder) {
    final isCompleted = reminder['completed'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              reminder['completed'] = !isCompleted;
            });
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted 
                          ? AppColors.primary
                          : AppColors.primaryContainer,
                      width: 2,
                    ),
                    color: isCompleted ? AppColors.primary : Colors.transparent,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    reminder['title'],
                    style: TextStyle(
                      fontSize: 18,
                      color: isCompleted 
                          ? const Color(0xFF596065)
                          : const Color(0xFF2D3338),
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                // More options button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showReminderOptions(reminder);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Color(0xFF596065),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddReminderButton() {
    return GestureDetector(
      onTap: _showAddReminderDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFACB3B8).withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              size: 20,
              color: Color(0xFF596065),
            ),
            const SizedBox(width: 8),
            const Text(
              'Add New Reminder',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF596065),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    final controller = TextEditingController();
    bool hasText = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'New Reminder',
            style: TextStyle(
              fontSize: 20,
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
              labelText: 'Reminder name',
              hintText: 'e.g., Read for 20 minutes',
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
                        _reminderCounter++;
                        _reminders.add({
                          'id': 'reminder_$_reminderCounter',
                          'title': controller.text.trim(),
                          'completed': false,
                        });
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

  void _showReminderOptions(Map<String, dynamic> reminder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                setState(() {
                  _reminders.remove(reminder);
                });
                Navigator.of(ctx).pop();
                HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

   Widget _buildCalendarNav({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF596065),
            size: 20,
          ),
        ),
      ),
    );
  }

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday;
    final startOfWeek = today.subtract(Duration(days: weekday - 1));
    
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getWeekdayLetter(int weekday) {
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return letters[weekday - 1];
  }
}