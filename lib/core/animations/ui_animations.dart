import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system.dart';

/// Централизованный файл для всех UI анимаций
/// Используется на всех страницах для единообразия

// ==================== HOVER ЭФФЕКТЫ ====================

/// Hover-эффект для карточек (поднятие вверх)
class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final double hoverOffset;
  final double hoverScale;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;

  const HoverScaleCard({
    super.key,
    required this.child,
    this.hoverOffset = -4.0,
    this.hoverScale = 1.0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.onTap,
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? widget.hoverOffset : 0.0),
          child: Transform.scale(
            scale: _isHovered ? widget.hoverScale : 1.0,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Hover-эффект с изменением тени
class HoverShadowCard extends StatelessWidget {
  final Widget child;
  final double hoverElevation;
  final double normalElevation;
  final VoidCallback? onTap;

  const HoverShadowCard({
    super.key,
    required this.child,
    this.hoverElevation = 12.0,
    this.normalElevation = 4.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isHovered ? 0.12 : 0.04),
                    blurRadius: isHovered ? 30 : 20,
                    offset: Offset(0, isHovered ? 12 : 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ==================== АНИМАЦИЯ ПОЯВЛЕНИЯ ====================

/// Анимация появления элементов (fade in + slide up)
class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final double beginOffset;
  final Duration duration;
  final Duration delay;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.beginOffset = 20.0,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Opacity(opacity: 0, child: SizedBox.shrink());
        }
        return TweenAnimationBuilder<double>(
          duration: duration,
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, beginOffset * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

/// Стиaggered анимация для списка (элементы появляются по очереди)
class StaggeredListAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration startDelay;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 100),
    this.startDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return FadeSlideTransition(
          delay: startDelay + Duration(milliseconds: index * itemDuration.inMilliseconds),
          child: child,
        );
      }).toList(),
    );
  }
}

// ==================== АНИМАЦИЯ ДЛЯ КАРТОЧЕК ====================

/// Анимация для карточек дней недели (как в HTML)
class DayCardAnimation extends StatefulWidget {
  final Widget child;
  final bool isToday;
  final VoidCallback? onTap;

  const DayCardAnimation({
    super.key,
    required this.child,
    this.isToday = false,
    this.onTap,
  });

  @override
  State<DayCardAnimation> createState() => _DayCardAnimationState();
}

class _DayCardAnimationState extends State<DayCardAnimation> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _entranceAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _entranceAnimation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _entranceAnimation.value)),
                child: Transform.scale(
                  scale: 0.95 + (0.05 * _entranceAnimation.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.02),
                          blurRadius: _isHovered ? 30 : 20,
                          offset: Offset(0, _isHovered ? 12 : 8),
                        ),
                      ],
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================== АНИМАЦИЯ ДЛЯ ЧЕКБОКСОВ ====================

/// Анимированный чекбокс (как в HTML)
class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 20.0,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.value
                      ? AppColors.primary
                      : AppColors.primaryContainer,
                  width: 2,
                ),
                color: widget.value ? AppColors.primary : Colors.transparent,
              ),
              child: widget.value
                  ? Transform.scale(
                      scale: _checkAnimation.value,
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// ==================== АНИМАЦИЯ ПУЛЬСАЦИИ ====================

/// Анимация пульсации (для активных элементов)
class PulsingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulsingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minScale = 0.98,
    this.maxScale = 1.02,
  });

  @override
  State<PulsingAnimation> createState() => _PulsingAnimationState();
}

class _PulsingAnimationState extends State<PulsingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

// ==================== АНИМАЦИЯ ДЛЯ ЗАДАЧ (TO-DO) ====================

/// Анимация для карточек задач (staggered + slide)
class TaskCardAnimation extends StatelessWidget {
  final Widget child;
  final int index;
  final bool isCompleted;

  const TaskCardAnimation({
    super.key,
    required this.child,
    required this.index,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              isCompleted ? 20 * (1 - value) : -20 * (1 - value),
              0,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ==================== GLOW ЭФФЕКТ (как в HTML) ====================

/// Glow-эффект при наведении
class GlowOnHover extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;

  const GlowOnHover({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.glowIntensity = 0.15,
  });

  @override
  State<GlowOnHover> createState() => _GlowOnHoverState();
}

class _GlowOnHoverState extends State<GlowOnHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(widget.glowIntensity),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}