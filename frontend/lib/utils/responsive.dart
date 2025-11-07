/// Responsive Utilities
/// 
/// Provides screen size detection and responsive helpers.
/// Keep this file minimal - only detection and generic helpers!

import 'package:flutter/material.dart';

/// Screen size breakpoints and detection utilities
class Responsive {
  // Breakpoint constants
  static const double mobileMax = 600;
  static const double tabletMax = 900;
  
  /// Check if screen is mobile size (< 600px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;
  
  /// Check if screen is tablet size (600px - 900px)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMax &&
      MediaQuery.of(context).size.width < tabletMax;
  
  /// Check if screen is desktop size (>= 900px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;
  
  /// Get number of columns based on screen size
  static int getColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3; // Desktop
  }
  
  /// Get responsive value based on screen size
  static T getValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }
}

/// Generic responsive builder widget
/// 
/// Displays different widgets based on screen size.
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(), // optional
///   desktop: DesktopWidget(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return mobile;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return desktop;
    }
  }
}

