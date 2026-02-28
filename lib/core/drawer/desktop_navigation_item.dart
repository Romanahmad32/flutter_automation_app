library desktop_navigation_menu;

import 'desktop_menu_item.dart';

import 'package:flutter/material.dart';

/// Represents an Item in the
/// Navigation Bar and it's corresponding Screen.
class DesktopNavigationItem {
  const DesktopNavigationItem({
    required this.menuItem,
    required this.screen,
  });

  /// The Item that is shown inside
  /// of the Navigation Menu Bar.
  final DesktopMenuItem menuItem;

  /// The corresponding Screen for
  /// that Item.
  final Widget screen;
}