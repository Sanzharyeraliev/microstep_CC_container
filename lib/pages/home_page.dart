
import 'dart:ui';
import '../widgets/burger_menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';
import '../widgets/progress_card.dart';
import '../widgets/self_care_card.dart';
import '../widgets/declutter_card.dart';
import '../widgets/learn_card.dart';
import 'declutter_page.dart';
import 'learn/learn_page.dart';
import 'journal/journal_page.dart';
import 'progress_page.dart';
import 'settings/settings_page.dart';
import 'profile_page.dart';
import 'check_page.dart';

// String-based section identifiers for better flexibility
const String sectionHome = 'home';
const String sectionDeclutter = 'declutter';
const String sectionJournal = 'journal';
const String sectionLearn = 'learn';
const String sectionCheck = 'check';
const String sectionProgress = 'progress';
const String sectionAwards = 'awards';
const String sectionProfile = 'profile';
const String sectionSettings = 'settings';





class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const double _drawerWidth = 360.0;
  String _currentSection = sectionHome;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String? _pendingSection;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.addStatusListener((status) {
      print('Animation status changed to: $status');
      if (status == AnimationStatus.dismissed) {
        print('Animation dismissed, checking for pending section');
        if (_pendingSection != null) {
          print('Navigating to pending section: $_pendingSection');
          setState(() {
            _currentSection = _pendingSection!;
            _pendingSection = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    print('Burger menu toggle - Current status: ${_animationController.status}');
    if (_animationController.isCompleted) {
      print('Closing burger menu');
      _animationController.reverse();
    } else {
      print('Opening burger menu');
      _animationController.forward();
    }
  }

  void _closeDrawer() {
    print('Close drawer called - Current status: ${_animationController.status}');
    if (_animationController.status != AnimationStatus.dismissed) {
      print('Reversing animation to close drawer');
      _animationController.reverse();
    } else {
      print('Drawer already closed');
    }
  }

  void _navigateToSection(String section) {
    print('Navigation requested to section: $section');
    if (section == 'logout') {
      // Handle logout
      print('Handling logout navigation');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    // If we're already on the section, just close the drawer.
    if (_currentSection == section) {
      print('Already on section $section, closing drawer');
      _closeDrawer();
      return;
    }

    // Set the pending section and start closing the drawer.
    // The animation listener will perform the navigation when the drawer is hidden.
    _pendingSection = section;
    print('Setting pending section to: $section, closing drawer');
    _closeDrawer();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Main content
        _buildMainContent(),
        
        // Bottom Navigation Bar (only on home)
        if (_currentSection == sectionHome) _buildBottomNavBar(),
        
        // Decorative circles
        Positioned(
          top: -96,
          right: -96,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2,
          left: -96,
          child: Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary.withOpacity(0.05),
            ),
          ),
        ),
  // Burger Menu Drawer
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              left: -_drawerWidth + (_drawerWidth * _animation.value),
              top: 0,
              bottom: 0,
              width: _drawerWidth,
              child: BurgerMenuDrawer(
                onNavigate: _navigateToSection,
                currentSection: _currentSection,
              ),
            );
          },
        ),
      ],
    ),
  );
}

  Widget _buildMainContent() {
    final openMenu = () => _toggleDrawer();

    switch (_currentSection) {
      case sectionHome:
        return _buildHomePage();
      case sectionDeclutter:
        return DeclutterPage(onMenuTap: openMenu);
      case sectionJournal:
        return JournalPage(onMenuTap: openMenu);
      case sectionLearn:
        return LearnPage(onMenuTap: openMenu);
      case sectionCheck:
        return CheckPage(onMenuTap: openMenu);
      case sectionProgress:
        return ProgressPage(onMenuTap: openMenu);
      case sectionAwards:
        return _buildPlaceholderPage('Awards', openMenu);
      case sectionProfile:
        return ProfilePage(onMenuTap: openMenu);
      case sectionSettings:
        return SettingsPage(onMenuTap: openMenu);
      default:
        return _buildHomePage();
    }
  }

  Widget _buildPlaceholderPage(String title, VoidCallback onMenuTap) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onMenuTap,
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
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.construction_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '$title coming soon',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'This section is under development',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
     return RepaintBoundary(  // ← Добавить
    child: SafeArea(
      child: Column(
        children: [
          _buildTopAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ).copyWith(
                top: AppSpacing.lg,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingSection(dateStr),
                  const SizedBox(height: AppSpacing.xl),
                  const RepaintBoundary(child: ProgressCard()),  // ← Добавить
                  const SizedBox(height: AppSpacing.xl),
                  const SizedBox(height: AppSpacing.lg),
                  const RepaintBoundary(child: SelfCareCard()),  // ← Добавить
                  const SizedBox(height: AppSpacing.lg),
                  const RepaintBoundary(child: DeclutterCard()),  // ← Добавить
                  const SizedBox(height: AppSpacing.lg),
                  const RepaintBoundary(child: LearnCard()),  // ← Добавить
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button (always opens burger menu)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('Menu button clicked');
                _toggleDrawer();
              },
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
          // Title
          Text(
            _currentSection == sectionHome ? 'MicroStep' : _getSectionTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: AppColors.onSurface,
            ),
          ),
          // Notifications button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => HapticFeedback.lightImpact(),
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSectionTitle() {
    switch (_currentSection) {
      case sectionDeclutter:
        return 'Declutter';
      case sectionJournal:
        return 'Journal';
      case sectionLearn:
        return 'Learn';
      case sectionCheck:
        return 'Check';
      case sectionProgress:
        return 'Progress';
      case sectionAwards:
        return 'Awards';
      case sectionProfile:
        return 'Profile';
      case sectionSettings:
        return 'Settings';
      default:
        return 'MicroStep';
    }
  }

  Widget _buildGreetingSection(String dateStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Доброе утро, Алексей!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          '3 микро-действия сделают этот день лучше',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ).copyWith(bottom: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Active Home button with gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: signatureGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _navigateToSection(sectionHome);
                      },
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Icon(
                          Icons.home,
                          color: AppColors.onPrimary,
                          size: 28,
                          fill: 1,
                        ),
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



  String _formatDate(DateTime date) {
    const weekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];
    const months = [
      '',
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month]}';
  }
}