
library desktop_navigation_menu;

import 'desktop_menu_item.dart';
import 'navigation_menu_bar.dart';
import 'desktop_navigation_item.dart';

import 'package:flutter/material.dart';

/// A Side Navigation Bar on the left Side
/// of the Screen.
///
/// Is designed to be used in Desktop
/// Applications.
class DesktopNavigationMenu extends StatefulWidget {
  const DesktopNavigationMenu({
    required this.views,
    this.width,
    this.withDivider = true,
    Key? key,
  }) : super(key: key);

  /// The Views for the Navigation Bar.
  final List<DesktopNavigationItem> views;

  /// The width of this Menu.
  final double? width;

  /// Whether there should be a divider
  /// between the Navigation Menu and the
  /// Screen.
  ///
  /// Defaults to true.
  final bool withDivider;

  @override
  State<StatefulWidget> createState() => _DesktopNavigationMenuState();
}

class _DesktopNavigationMenuState extends State<DesktopNavigationMenu> {
  /// The index indicating which view
  /// should be shown at a specific moment.
  int _index = 0;

  /// The width of this Screen.
  double? width;

  @override
  Widget build(BuildContext context) {
    // check and set width.
    if (widget.width != null) {
      width = widget.width;
    } else {
      final MediaQueryData mq = MediaQuery.of(context);

      if (mq.size.width / 5 < 150) {
        width = 150;
      } else {
        width = mq.size.width / 5;
      }
    }

    return _body;
  }

  /// The Body of this Widget.
  Row get _body {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      textBaseline: TextBaseline.alphabetic,
      textDirection: TextDirection.ltr,
      verticalDirection: VerticalDirection.down,
      children: _children,
    );
  }

  /// The Items for the [NavigationMenuBar].
  ///
  /// This Method extracts the items of every
  /// single [DesktopNavigationItem] into
  /// a List of [DesktopMenuItemWidget]
  List<DesktopMenuItemWidget> get _items {
    final List<DesktopMenuItemWidget> list = [];
    for (int c = 0; c < widget.views.length; c++) {
      /// The current Menu Item in the Iteration
      final DesktopMenuItem menuItem = widget.views[c].menuItem;

      bool isSelected = _index == c;

      list.add(
        DesktopMenuItemWidget(
          isSelected: isSelected,
          label: menuItem.label,
          description: menuItem.description,
          icon: menuItem.icon,
          activeIcon: menuItem.activeIcon,
          onTap: () => _indexChanged(c),
        ),
      );
    }
    return list;
  }

  /// Returns the Children
  /// of the Row.
  List<Widget> get _children {
    return [
      NavigationMenuBar(
        items: _items,
        width: width!,
      ),
      // Add Divider if wanted
      // by the User.
          () {
        if (widget.withDivider) {
          return const VerticalDivider();
        } else {
          return Container();
        }
      }(),
      Expanded(
        child: _currentView,
      ),
    ];
  }

  /// Returns the current View.
  Widget get _currentView {
    return widget.views[_index].screen;
  }

  /// Called when the index of
  /// the [NavigationMenuBar]'s current Item
  /// changes.
  void _indexChanged(int i) => setState(() {
    _index = i;
  });
}