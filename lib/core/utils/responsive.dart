import 'package:flutter/material.dart';

/// Responsive design helpers and breakpoints for Mobile, Tablet, and Desktop web.
class Responsive {
  static const double mobileMaxWidth = 600.0;
  static const double tabletMaxWidth = 1024.0;
  static const double maxContentWidth = 1200.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileMaxWidth &&
      MediaQuery.sizeOf(context).width < tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;
}
