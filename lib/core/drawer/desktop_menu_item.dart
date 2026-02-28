library desktop_navigation_menu;

import 'package:flutter/material.dart';

@protected
class DesktopMenuItem {
  const DesktopMenuItem({
    required this.label,
    this.description,
    this.icon,
    this.activeIcon,
  });

  /// The Label for
  /// this Menu Item.
  ///
  /// This should be short
  /// and precice.
  final String label;

  /// The Description
  /// for this Item.
  /// This is shown underneeth
  /// the Label.
  ///
  /// Can be longer than the
  /// label, but should also be short,
  /// precice and not longer than one sentence.
  final String? description;

  /// The Icon for this
  /// Item.
  final Icon? icon;

  /// The Icon that is shown, when this Item is
  /// selected.
  final Icon? activeIcon;
}

/// A single Item inside
/// of the Navigation Bar.
class DesktopMenuItemWidget extends StatelessWidget {
  const DesktopMenuItemWidget({
    required this.label,
    required this.onTap,
    this.description,
    this.icon,
    this.activeIcon,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  /// The Label for
  /// this Menu Item.
  ///
  /// This should be short
  /// and precice.
  final String label;

  /// The Description
  /// for this Item.
  /// This is shown underneeth
  /// the Label.
  ///
  /// Can be longer than the
  /// label, but should also be short,
  /// precice and not longer than one sentence.
  final String? description;

  /// The Icon for this
  /// Item.
  final Icon? icon;

  /// The Icon that is shown, when this Item is
  /// selected.
  final Icon? activeIcon;

  /// The Function called when
  /// this Widget is clicked.
  final void Function() onTap;

  /// Whether this Tile is clicked or not.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      autofocus: false,
      enableFeedback: true,
      enabled: true,
      isThreeLine: false,
      leading: isSelected ? activeIcon : icon,
      title: Text(label),
      subtitle: description != null ? Text(description!) : null,
      onTap: onTap,
    );
  }
}