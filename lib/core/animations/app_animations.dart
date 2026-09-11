import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Global animation configuration for the app.
/// These values create a consistent, professional feel across all animations.
class AppAnimations {
  AppAnimations._();

  // ══════════════════════════════════════════════════════════════════════════
  // DURATION PRESETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Ultra-fast micro-interactions (button press, ripple)
  static const Duration ultraFast = Duration(milliseconds: 100);

  /// Fast animations (small state changes, icon swaps)
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal animations (standard transitions)
  static const Duration normal = Duration(milliseconds: 300);

  /// Medium animations (card reveals, moderate movements)
  static const Duration medium = Duration(milliseconds: 400);

  /// Slow animations (page transitions, complex reveals)
  static const Duration slow = Duration(milliseconds: 500);

  /// Very slow animations (onboarding, emphasis effects)
  static const Duration verySlow = Duration(milliseconds: 700);

  // ══════════════════════════════════════════════════════════════════════════
  // CURVE PRESETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Default curve for most animations (smooth ease out)
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Bounce curve for playful interactions
  static const Curve bounceCurve = Curves.elasticOut;

  /// Snappy curve for quick interactions
  static const Curve snappyCurve = Curves.easeOutBack;

  /// Smooth decelerate for slide-ins
  static const Curve slideInCurve = Curves.decelerate;

  /// Emphasized curve for attention-grabbing
  static const Curve emphasisCurve = Curves.easeInOutCubic;

  // ══════════════════════════════════════════════════════════════════════════
  // STAGGER DELAYS
  // ══════════════════════════════════════════════════════════════════════════

  /// Delay between staggered list items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Longer delay for card grids
  static const Duration gridStaggerDelay = Duration(milliseconds: 80);

  /// Delay for section reveals
  static const Duration sectionDelay = Duration(milliseconds: 100);

  // ══════════════════════════════════════════════════════════════════════════
  // OFFSET PRESETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subtle slide offset
  static const Offset slideUpSmall = Offset(0, 20);

  /// Normal slide offset
  static const Offset slideUpNormal = Offset(0, 30);

  /// Large slide offset
  static const Offset slideUpLarge = Offset(0, 50);

  /// Slide from left
  static const Offset slideFromLeft = Offset(-30, 0);

  /// Slide from right
  static const Offset slideFromRight = Offset(30, 0);

  // ══════════════════════════════════════════════════════════════════════════
  // SCALE PRESETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subtle press scale
  static const double pressScale = 0.95;

  /// Tap bounce scale
  static const double tapBounceScale = 0.9;

  /// Initial reveal scale
  static const double revealScale = 0.8;

  /// Attention scale
  static const double attentionScale = 1.05;
}

/// Extension methods for adding professional animations to any widget.
extension AppAnimateExtensions on Widget {
  // ══════════════════════════════════════════════════════════════════════════
  // ENTRANCE ANIMATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Fade in with slide up - perfect for list items and cards
  Widget fadeInSlideUp({
    Duration? duration,
    Duration? delay,
    Offset? offset,
    Curve? curve,
  }) {
    return animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.defaultCurve,
        )
        .slideY(
          begin: (offset?.dy ?? AppAnimations.slideUpNormal.dy) / 100,
          end: 0,
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.defaultCurve,
        );
  }

  /// Fade in with scale - great for cards and images
  Widget fadeInScale({
    Duration? duration,
    Duration? delay,
    double? beginScale,
    Curve? curve,
  }) {
    return animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.defaultCurve,
        )
        .scale(
          begin: Offset(
            beginScale ?? AppAnimations.revealScale,
            beginScale ?? AppAnimations.revealScale,
          ),
          end: const Offset(1, 1),
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.snappyCurve,
        );
  }

  /// Slide in from left
  Widget slideInFromLeft({Duration? duration, Duration? delay, Curve? curve}) {
    return animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.defaultCurve,
        )
        .slideX(
          begin: -0.3,
          end: 0,
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.slideInCurve,
        );
  }

  /// Slide in from right
  Widget slideInFromRight({Duration? duration, Duration? delay, Curve? curve}) {
    return animate(delay: delay)
        .fadeIn(
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.defaultCurve,
        )
        .slideX(
          begin: 0.3,
          end: 0,
          duration: duration ?? AppAnimations.normal,
          curve: curve ?? AppAnimations.slideInCurve,
        );
  }

  /// Pop in with bounce - attention-grabbing
  Widget popIn({Duration? duration, Duration? delay, Curve? curve}) {
    return animate(delay: delay)
        .fadeIn(duration: duration ?? AppAnimations.fast)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: duration ?? AppAnimations.medium,
          curve: curve ?? AppAnimations.bounceCurve,
        );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTERACTION ANIMATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Shimmer effect for loading states or highlights
  Widget shimmer({Duration? duration, Color? color}) {
    return animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: duration ?? const Duration(milliseconds: 1500),
      color: color ?? Colors.white.withValues(alpha: 0.3),
    );
  }

  /// Pulse animation for attention
  Widget pulse({Duration? duration}) {
    return animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: duration ?? const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  /// Shake animation for errors
  Widget shake({Duration? duration, double? offset}) {
    return animate().shake(
      duration: duration ?? AppAnimations.medium,
      hz: 4,
      offset: Offset(offset ?? 10, 0),
    );
  }
}

/// Extension for creating staggered list animations
extension StaggeredListAnimation on List<Widget> {
  /// Animate list items with stagger effect
  List<Widget> animateList({
    Duration? itemDuration,
    Duration? staggerDelay,
    Offset? slideOffset,
    bool fadeIn = true,
    bool slideUp = true,
  }) {
    return asMap().entries.map((entry) {
      final index = entry.key;
      final widget = entry.value;

      Widget animatedWidget = widget.animate(
        delay: (staggerDelay ?? AppAnimations.staggerDelay) * index,
      );

      if (fadeIn) {
        animatedWidget = (animatedWidget as Animate).fadeIn(
          duration: itemDuration ?? AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        );
      }

      if (slideUp) {
        animatedWidget = (animatedWidget as Animate).slideY(
          begin: (slideOffset?.dy ?? 20) / 100,
          end: 0,
          duration: itemDuration ?? AppAnimations.normal,
          curve: AppAnimations.defaultCurve,
        );
      }

      return animatedWidget;
    }).toList();
  }
}

/// Utility class for building complex animations
class AnimationBuilder {
  /// Creates a staggered entrance effect for a column of widgets
  static List<Widget> staggerColumn({
    required List<Widget> children,
    Duration? duration,
    Duration? staggerDelay,
    int startIndex = 0,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key + startIndex;
      return entry.value.fadeInSlideUp(
        delay: (staggerDelay ?? AppAnimations.staggerDelay) * index,
        duration: duration,
      );
    }).toList();
  }

  /// Creates a grid stagger effect
  static Widget staggerGrid({
    required List<Widget> children,
    required int crossAxisCount,
    Duration? duration,
    Duration? staggerDelay,
  }) {
    final animatedChildren = children.asMap().entries.map((entry) {
      final index = entry.key;
      // Calculate delay based on position (creates diagonal reveal)
      final row = index ~/ crossAxisCount;
      final col = index % crossAxisCount;
      final diagonalIndex = row + col;

      return entry.value.fadeInScale(
        delay: (staggerDelay ?? AppAnimations.gridStaggerDelay) * diagonalIndex,
        duration: duration,
      );
    }).toList();

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: animatedChildren,
    );
  }
}
