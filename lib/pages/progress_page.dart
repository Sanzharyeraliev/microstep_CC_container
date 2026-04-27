import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';
import '../widgets/progress_card.dart';

class ProgressPage extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const ProgressPage({super.key, this.onMenuTap});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Отслеживайте свой прогресс и достижения.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const ProgressCard(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildWeeklyStats(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAchievements(),
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
                'Progress',
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
    );
  }

  Widget _buildWeeklyStats() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика за неделю',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDayRow('Пн', 4, 5),
          const SizedBox(height: AppSpacing.sm),
          _buildDayRow('Вт', 3, 5),
          const SizedBox(height: AppSpacing.sm),
          _buildDayRow('Ср', 5, 5),
          const SizedBox(height: AppSpacing.sm),
          _buildDayRow('Чт', 2, 5),
          const SizedBox(height: AppSpacing.sm),
          _buildDayRow('Пт', 3, 5),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day, int completed, int total) {
    final progress = completed / total;
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$completed/$total',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Достижения',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildAchievement(
            icon: Icons.local_fire_department,
            title: '7 дней подряд',
            description: 'Неделя без перерывов',
            unlocked: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAchievement(
            icon: Icons.emoji_events,
            title: '50 микро-действий',
            description: 'Половина пути к мастерству',
            unlocked: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAchievement(
            icon: Icons.auto_awesome,
            title: '100 микро-действий',
            description: 'Мастер осознанности',
            unlocked: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement({
    required IconData icon,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.primaryContainer.withOpacity(0.3)
                : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: unlocked ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
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
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (unlocked)
          const Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 24,
          )
        else
          const Icon(
            Icons.lock_outline,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
      ],
    );
  }
}
