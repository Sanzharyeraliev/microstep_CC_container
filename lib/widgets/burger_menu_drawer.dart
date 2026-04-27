import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_system.dart';

typedef NavigationCallback = void Function(String section);

class BurgerMenuDrawer extends StatelessWidget {
  final NavigationCallback onNavigate;
  final String currentSection;

  const BurgerMenuDrawer({
    super.key,
    required this.onNavigate,
    this.currentSection = 'home',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 320, // w-80 = 320px
      height: double.infinity,
      child: Stack(
        children: [
          // Glassmorphism фон
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(32), // rounded-r-[2rem]
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withOpacity(0.35) // slate-900/80
                      : const Color(0xFFF8FAFC).withOpacity(0.35), // slate-50/80
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(32),
                  ),
                  image: DecorationImage(
                    image: const AssetImage('assets/images/burger_bg.png'),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? const Color(0xFF0F172A).withOpacity(0.35)
                          : const Color(0xFFF8FAFC).withOpacity(0.35),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24), // p-6
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(isDark),
                  const SizedBox(height: 32), // mb-8

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Home Group
                          _buildHomeGroup(isDark),
                          
                          // Organization Group
                          _buildOrganizationGroup(isDark),
                          
                          // Knowledge Group
                          _buildKnowledgeGroup(isDark),
                          
                          // Results Group
                          _buildResultsGroup(isDark),
                          
                          // Account Group
                          _buildAccountGroup(isDark),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Actions
                  _buildBottomActions(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 64, // w-16
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBnfW_TRBJHNrL3WG7f8jZpWkd3NXx6N2aIWVqOCldsrBnpeW-lkQZV3z9ywn5iHsrabXiJK0codXdzhbzBiYXjgV893JPR5vL4r5RWU55uSvb52TGNJdGj4iluC1xV3s9BGCaYvdWJ4OQ8uuvf2FSYZ1u7P40H9_RNp92gIAXofiPVmN2mWgW3TGe859XFe6-RNVc2MtdoglBnSDg1B8Wfsa9y9w1vWxh-z3lc5rrOfk8r6dDZVb8AflycITPAFuedkf4wKBGnWKcV',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE4E9EE),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF006D42),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16), // gap-4
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alex Rivers',
                    style: TextStyle(
                      fontSize: 20, // text-xl
                      fontWeight: FontWeight.w700, // font-bold
                      color: isDark 
                          ? const Color(0xFFD1FAE5) // emerald-100
                          : const Color(0xFF064E3B), // emerald-900
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Premium Member',
                    style: TextStyle(
                      fontSize: 11, // text-[11px]
                      fontWeight: FontWeight.w500, // font-medium
                      letterSpacing: 0.5, // tracking-widest
                      color: isDark 
                          ? const Color(0xFF94A3B8) // slate-400
                          : const Color(0xFF64748B), // slate-500
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Daily Focus
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Daily Focus: 4h 20m',
            style: TextStyle(
              fontSize: 14, // text-sm
              fontWeight: FontWeight.w600, // font-semibold
              color: isDark 
                  ? const Color(0xFF34D399) // emerald-400
                  : const Color(0xFF065F46), // emerald-800
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHomeGroup(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // mb-4
      child: Column(
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            title: 'Home',
            section: 'home',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrganizationGroup(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ORGANIZATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF94A3B8), // slate-400
              ),
            ),
          ),
          _buildNavItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            title: 'Declutter',
            section: 'declutter',
            isDark: isDark,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book,
            title: 'Journal',
            section: 'journal',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildKnowledgeGroup(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'KNOWLEDGE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          _buildNavItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            title: 'Learn',
            section: 'learn',
            isDark: isDark,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.fact_check_outlined,
            activeIcon: Icons.fact_check,
            title: 'Check',
            section: 'check',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultsGroup(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'RESULTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          _buildNavItem(
            icon: Icons.trending_up_outlined,
            activeIcon: Icons.trending_up,
            title: 'Progress',
            section: 'progress',
            isDark: isDark,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            title: 'Awards',
            section: 'awards',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountGroup(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          _buildNavItem(
            icon: Icons.account_circle_outlined,
            activeIcon: Icons.account_circle,
            title: 'Profile',
            section: 'profile',
            isDark: isDark,
          ),
          const SizedBox(height: 4),
          _buildNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            title: 'Settings',
            section: 'settings',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActions(bool isDark) {
    return Column(
      children: [
        // Divider
        Container(
          height: 1,
          color: const Color(0xFFCBD5E1).withOpacity(0.2), // slate-200/20
          margin: const EdgeInsets.only(bottom: 24),
        ),
       
        const SizedBox(height: 16),
        // Version
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            'Version 2.4.0 • Serene Pulse',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.5,
              color: const Color(0xFF94A3B8), // slate-400
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String section,
    required bool isDark,
  }) {
    final isActive = currentSection == section;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNavigate(section),
        borderRadius: BorderRadius.circular(16), // rounded-2xl
        hoverColor: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04),
        splashColor: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark
                    ? const Color(0xFF064E3B).withOpacity(0.4) // emerald-900/40
                    : const Color(0xFFD1FAE5).withOpacity(0.6)) // emerald-100/60
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: isDark
                        ? const Color(0xFF065F46).withOpacity(0.2) // emerald-800/20
                        : const Color(0xFFA7F3D0).withOpacity(0.2), // emerald-200/20
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive
                    ? (isDark 
                        ? const Color(0xFFD1FAE5) // emerald-100
                        : const Color(0xFF064E3B)) // emerald-900
                    : (isDark 
                        ? const Color(0xFFCBD5E1) // slate-300
                        : const Color(0xFF475569)), // slate-600
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? (isDark 
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFF064E3B))
                      : (isDark 
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}