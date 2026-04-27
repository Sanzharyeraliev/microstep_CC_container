import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system.dart';

/// AboutPage — точная копия из about/code.html
class AboutPage extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const AboutPage({super.key, this.onMenuTap});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: -80,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            right: -80,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.1),
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        // App Identity Section
                        _buildIdentitySection(),
                        const SizedBox(height: 32),
                        // What's New Section
                        _buildWhatsNewSection(),
                        const SizedBox(height: 32),
                        // Technical Info Grid
                        _buildTechnicalInfoGrid(),
                        const SizedBox(height: 32),
                        // Feedback & Links
                        _buildFeedbackSection(),
                        const SizedBox(height: 32),
                        // Legal Links
                        _buildLegalFooter(),
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.white.withOpacity(0.7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onMenuTap,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color(0xFF006D42),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: Color(0xFF006D42),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Abstract SVG-like blob
        Positioned(
          top: -48,
          child: SizedBox(
            width: 300,
            height: 256,
            child: CustomPaint(
              painter: _BlobPainter(),
            ),
          ),
        ),
        Column(
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.95 + (0.05 * _animationController.value),
                  child: Opacity(
                    opacity: 0.9 + (0.1 * _animationController.value),
                    child: child,
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96 + 32,
                    height: 96 + 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      gradient: signatureGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.energy_savings_leaf,
                          size: 44,
                          color: AppColors.primary,
                          fill: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MicroStep',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 16),
            // Rating & badges
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildBadge(
                  icon: Icons.star,
                  iconFill: true,
                  text: '4.8 Rating',
                  bgColor: AppColors.surfaceContainerLow,
                  textColor: AppColors.onSurface,
                  iconColor: AppColors.primary,
                  borderColor: AppColors.outlineVariant.withOpacity(0.1),
                ),
                _buildBadge(
                  icon: Icons.verified,
                  iconFill: true,
                  text: "Editor's Choice",
                  bgColor: AppColors.primary.withOpacity(0.1),
                  textColor: const Color(0xFF85E8AE),
                  iconColor: const Color(0xFF85E8AE),
                  borderColor: AppColors.primary.withOpacity(0.2),
                  isBold: true,
                  isUppercase: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Join 10M+ users worldwide',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required bool iconFill,
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
    required Color borderColor,
    bool isBold = false,
    bool isUppercase = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
            fill: iconFill ? 1 : 0,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textColor,
              letterSpacing: isUppercase ? 1 : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNewSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What's New",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 3.2.4 • May 20, 2026',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.new_releases,
                color: AppColors.primaryContainer,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildChangeItem(
            title: 'Improved Dark Mode',
            subtitle: 'Redesigned deep surface tones for better readability in low light environments.',
          ),
          const SizedBox(height: 16),
          _buildChangeItem(
            title: 'New Journal Templates',
            subtitle: 'Three new mindfulness structures added to your daily reflection toolkit.',
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: AppColors.outlineVariant.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => HapticFeedback.lightImpact(),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'View version history',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeItem({required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTechCard(
                icon: Icons.memory,
                label: 'Size',
                value: '124 MB',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTechCard(
                icon: Icons.ad_units,
                label: 'Min OS',
                value: 'iOS 16.0+',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Languages',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'English, Russian, Spanish',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 64,
                height: 32,
                child: Stack(
                  children: [
                    Positioned(left: 0, child: _buildLangCircle('EN')),
                    Positioned(left: 16, child: _buildLangCircle('RU')),
                    Positioned(left: 32, child: _buildLangCircle('ES')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangCircle(String code) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainer,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          code,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Community & Support',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSupportRow(
                icon: Icons.mail,
                iconColor: AppColors.primary,
                iconBg: const Color(0xFFECFDF5),
                title: 'Support Email',
                iconEnd: Icons.arrow_outward,
              ),
              Container(
                height: 1,
                color: AppColors.outlineVariant.withOpacity(0.1),
              ),
              _buildSupportRow(
                icon: Icons.send,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                title: 'Telegram',
                iconEnd: Icons.arrow_outward,
              ),
              Container(
                height: 1,
                color: AppColors.outlineVariant.withOpacity(0.1),
              ),
              _buildSupportRow(
                icon: Icons.close,
                iconColor: Colors.white,
                iconBg: const Color(0xFF0F172A),
                iconSize: 18,
                title: 'Twitter / X',
                iconEnd: Icons.arrow_outward,
              ),
              Container(
                height: 1,
                color: AppColors.outlineVariant.withOpacity(0.1),
              ),
              _buildSupportRow(
                icon: Icons.groups,
                iconColor: const Color(0xFF4F46E5),
                iconBg: const Color(0xFFEEF2FF),
                title: 'Discord',
                iconEnd: Icons.arrow_outward,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required IconData iconEnd,
    double iconSize = 24,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.lightImpact(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBg,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: iconSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Icon(
                iconEnd,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalFooter() {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          height: 1,
          color: AppColors.outlineVariant.withOpacity(0.1),
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 32),
            Text(
              'Terms of Use',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Made with Intention',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant.withOpacity(0.6),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2026 MicroStep Inc. All rights reserved.',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.onSurfaceVariant.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF93F7BC).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Simplified organic blob shape
    path.moveTo(size.width * 0.3, size.height * 0.1);
    path.cubicTo(
      size.width * 0.5, size.height * 0.05,
      size.width * 0.7, size.height * 0.15,
      size.width * 0.75, size.height * 0.3,
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.45,
      size.width * 0.7, size.height * 0.6,
      size.width * 0.55, size.height * 0.7,
    );
    path.cubicTo(
      size.width * 0.4, size.height * 0.8,
      size.width * 0.2, size.height * 0.75,
      size.width * 0.1, size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.0, size.height * 0.45,
      size.width * 0.05, size.height * 0.25,
      size.width * 0.15, size.height * 0.15,
    );
    path.cubicTo(
      size.width * 0.25, size.height * 0.05,
      size.width * 0.3, size.height * 0.1,
      size.width * 0.3, size.height * 0.1,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Circle
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.25),
      20,
      Paint()..color = const Color(0xFFDDE3E9).withOpacity(0.6),
    );

    // Wave line
    final wavePaint = Paint()
      ..color = const Color(0xFFACB3B8).withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final wavePath = Path();
    wavePath.moveTo(size.width * 0.1, size.height * 0.75);
    wavePath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.6,
      size.width * 0.5, size.height * 0.75,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.9,
      size.width * 0.9, size.height * 0.75,
    );
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
