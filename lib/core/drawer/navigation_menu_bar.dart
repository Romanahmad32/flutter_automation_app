library desktop_navigation_menu;

import 'desktop_menu_item.dart';

import 'package:flutter/material.dart';

/// The actual Navigation Menu Bar
/// for Desktoo Applications.
@protected
class NavigationMenuBar extends StatefulWidget {
  const NavigationMenuBar({
    required this.items,
    required this.width,
    Key? key,
  }) : super(key: key);


  /// The Items on this Bar.
  final List<DesktopMenuItemWidget> items;

  /// The width of the Navigation Menu Bar
  final double width;

  @override
  State<NavigationMenuBar> createState() => _NavigationMenuBarState();
}

class _NavigationMenuBarState extends State<NavigationMenuBar> {
  @override
  Widget build(BuildContext context) {
    return _bar;
  }

  /// The bar of this
  /// Navigation Bar.
  Widget get _bar {
    return SizedBox(
      width: widget.width,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        textBaseline: TextBaseline.alphabetic,
        textDirection: TextDirection.ltr,
        verticalDirection: VerticalDirection.down,
        children: widget.items,
      ),
      // ),
    );
  }
}