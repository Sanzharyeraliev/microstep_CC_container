import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system.dart';

/// NotificationsAndSoundPage — точная копия из notification and sound/code.html
class NotificationsAndSoundPage extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const NotificationsAndSoundPage({super.key, this.onMenuTap});

  @override
  State<NotificationsAndSoundPage> createState() => _NotificationsAndSoundPageState();
}

class _NotificationsAndSoundPageState extends State<NotificationsAndSoundPage> {
  // Organization
  bool _orgNotifications = true;
  bool _orgSound = true;
  String _orgSoundName = 'Soft Pulse';

  // Knowledge
  bool _knowNotifications = true;
  bool _knowSound = false;
  String _knowSoundName = 'Calm Bell';

  // Results
  bool _resNotifications = true;
  bool _resSound = true;
  String _resSoundName = 'Morning Dew';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Visual decoration (asymmetric touch)
          Positioned(
            top: 160,
            right: -80,
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
            bottom: 80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
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
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Customize how MicroStep speaks to you throughout your day.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Organization Group
                        _buildSection(
                          header: 'Organization',
                          hasDivider: false,
                          children: [
                            _buildToggleRow(
                              title: 'Allow Notifications',
                              subtitle: 'Get alerts for task deadlines',
                              value: _orgNotifications,
                              onChanged: (v) => setState(() => _orgNotifications = v),
                            ),
                            const SizedBox(height: 32),
                            _buildToggleRow(
                              title: 'Sound',
                              subtitle: 'Play audio for reminders',
                              value: _orgSound,
                              onChanged: (v) => setState(() => _orgSound = v),
                            ),
                            const SizedBox(height: 32),
                            _buildPickerRow(
                              title: 'Notification Sound',
                              value: _orgSoundName,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Knowledge Group
                        _buildSection(
                          header: 'Knowledge',
                          hasDivider: true,
                          children: [
                            _buildToggleRow(
                              title: 'Allow Notifications',
                              subtitle: 'New insights and articles',
                              value: _knowNotifications,
                              onChanged: (v) => setState(() => _knowNotifications = v),
                            ),
                            const SizedBox(height: 32),
                            _buildToggleRow(
                              title: 'Sound',
                              subtitle: 'Alert for new content',
                              value: _knowSound,
                              onChanged: (v) => setState(() => _knowSound = v),
                            ),
                            const SizedBox(height: 32),
                            _buildPickerRow(
                              title: 'Notification Sound',
                              value: _knowSoundName,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Results Group
                        _buildSection(
                          header: 'Results',
                          hasDivider: false,
                          children: [
                            _buildToggleRow(
                              title: 'Allow Notifications',
                              subtitle: 'Weekly progress summaries',
                              value: _resNotifications,
                              onChanged: (v) => setState(() => _resNotifications = v),
                            ),
                            const SizedBox(height: 32),
                            _buildToggleRow(
                              title: 'Sound',
                              subtitle: 'Celebrate achievements',
                              value: _resSound,
                              onChanged: (v) => setState(() => _resSound = v),
                            ),
                            const SizedBox(height: 32),
                            _buildPickerRow(
                              title: 'Notification Sound',
                              value: _resSoundName,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Aesthetic Footer
                        Opacity(
                          opacity: 0.4,
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Focus on the essential',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
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

  Widget _buildTopAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.surface.withOpacity(0.8),
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
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Notification & Sound',
                        style: TextStyle(
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
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String header,
    required bool hasDivider,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text(
              header,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            if (hasDivider) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.outlineVariant.withOpacity(0.1),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Glass card
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D3338).withOpacity(0.04),
                blurRadius: 48,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        _buildGradientSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildGradientSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          gradient: value
              ? signatureGradient
              : null,
          color: value ? null : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: value ? 28 : 4,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD1D5DB),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerRow({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
