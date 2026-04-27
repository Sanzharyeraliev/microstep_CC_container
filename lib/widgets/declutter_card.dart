import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';

/// Карточка Declutter (Document.pdf)
class DeclutterCard extends StatelessWidget {
  const DeclutterCard({super.key});

  @override 
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document.pdf',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '1.2 MB • Загружено вчера',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Keep',
                  textColor: AppColors.primary,
                  backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
                  hoverColor: AppColors.primaryContainer.withOpacity(0.4),
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Trash',
                  textColor: AppColors.onSurfaceVariant,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  hoverColor: AppColors.surfaceContainerHighest,
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Delete',
                  textColor: AppColors.onErrorContainer,
                  backgroundColor: AppColors.errorContainer.withOpacity(0.2),
                  hoverColor: AppColors.errorContainer.withOpacity(0.4),
                  onTap: () => HapticFeedback.lightImpact(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color hoverColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.md,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
