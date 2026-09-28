import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout rules that keep Flowsy looking right on phones, foldables and
/// tablets (portrait and landscape).
class Responsive {
  Responsive._();

  /// The phone size the UI was designed against.
  static const Size baseDesignSize = Size(360, 690);

  /// ScreenUtil scales `.w`, `.h`, `.sp` and `.r` by screen / design size.
  /// Without a cap an iPad makes everything ~2.5x bigger, so we never let
  /// the factor grow past this.
  static const double maxScale = 1.2;

  /// Width at which the layout is treated as a tablet.
  static const double tabletBreakpoint = 600;

  /// Width at which screens can show two columns side by side.
  static const double wideBreakpoint = 1000;

  /// Max content widths so forms and lists don't stretch edge to edge.
  static const double formMaxWidth = 520;
  static const double contentMaxWidth = 720;
  static const double wideMaxWidth = 1160;

  /// Design size to hand to ScreenUtil for the current screen. It grows
  /// with the screen once the scale would pass [maxScale], which caps it.
  static Size designSizeFor(Size screen) {
    if (screen.isEmpty) return baseDesignSize;
    // In landscape the phone design is rotated too, so `.h` spacing doesn't
    // collapse on a short, wide screen.
    final base = screen.width > screen.height
        ? baseDesignSize.flipped
        : baseDesignSize;
    return Size(
      math.max(base.width, screen.width / maxScale),
      math.max(base.height, screen.height / maxScale),
    );
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  /// Padding for a full-width scroll view that centres its content in a
  /// column no wider than [maxWidth]. Keeps the whole screen scrollable
  /// (unlike wrapping the list in a ConstrainedBox).
  static EdgeInsets scrollPadding(
    BuildContext context, {
    double maxWidth = contentMaxWidth,
    double horizontal = 20,
    double vertical = 20,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final side = math.max(horizontal.w, (width - maxWidth) / 2);
    return EdgeInsets.symmetric(horizontal: side, vertical: vertical.h);
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
