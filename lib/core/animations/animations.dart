/// Animation utilities for the app
///
/// This library provides a comprehensive set of animation tools:
///
/// - [AppAnimations] - Duration, curve, and offset presets
/// - [AppAnimateExtensions] - Widget extension methods for common animations
/// - [AnimatedTap] - Tap feedback wrapper
/// - [AnimatedButton] - Button with loading state animation
/// - [AnimatedCounter] - Animated number counter
/// - [AnimatedExpand] - Expandable content wrapper
/// - [AnimatedSlideVisibility] - Visibility with slide transition
/// - [AnimatedSkeleton] - Loading skeleton with shimmer
/// - [AnimatedRotatingIcon] - Icon with rotation animation
/// - [AnimatedPageRoute] - Custom page route with slide animation
///
/// Usage:
/// ```dart
/// import 'package:wallet_split/core/animations/animations.dart';
///
/// // Use extension methods
/// MyWidget().fadeInSlideUp(delay: 100.ms);
///
/// // Use animated widgets
/// AnimatedTap(
///   onTap: () => print('tapped'),
///   child: MyCard(),
/// );
/// ```
library;

export 'app_animations.dart';
export 'animated_widgets.dart';
