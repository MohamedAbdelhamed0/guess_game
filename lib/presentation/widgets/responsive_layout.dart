import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

/// Dynamic layout wrapper switching cleanly between mobile, tablet, and desktop views.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double maxContainerWidth;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.maxContainerWidth = Responsive.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget child;
        if (constraints.maxWidth >= Responsive.tabletMaxWidth && desktop != null) {
          child = desktop!;
        } else if (constraints.maxWidth >= Responsive.mobileMaxWidth && tablet != null) {
          child = tablet!;
        } else if (constraints.maxWidth >= Responsive.tabletMaxWidth && tablet != null) {
          child = tablet!;
        } else {
          child = mobile;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContainerWidth),
            child: child,
          ),
        );
      },
    );
  }
}
