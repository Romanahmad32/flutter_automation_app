import 'package:automation_app/core/general_widgets/drawer/side_bar_item.dart';
import 'package:automation_app/core/theme/presentation/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    required this.isExtended,
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.animationDuration,
    required this.activeIndex,
    required this.onDestinationSelected,
    required this.onToggle,
  });

  final bool isExtended;
  final double collapsedWidth;
  final double expandedWidth;
  final Duration animationDuration;
  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggle;

  static const _destinations = [
    (
    icon: Icons.document_scanner_outlined,
    selectedIcon: Icons.document_scanner,
    label: 'Word Automation',
    ),
    (
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Einstellungen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: isExtended ? expandedWidth : collapsedWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 64,
            width: collapsedWidth,
            child: Center(
              child: IconButton(
                onPressed: onToggle,
                icon: const Icon(Icons.menu),
                tooltip: isExtended ? 'Zuklappen' : 'Aufklappen',
              ),
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          for (final (index, dest) in _destinations.indexed)
            SidebarItem(
              icon: Icon(dest.icon),
              selectedIcon: Icon(dest.selectedIcon),
              label: dest.label,
              isSelected: activeIndex == index,
              isExtended: isExtended,
              animationDuration: animationDuration,
              collapsedWidth: collapsedWidth,
              onTap: () => onDestinationSelected(index),
            ),

          const Spacer(),
          const Divider(height: 1),

          SizedBox(
            height: 64,
            width: collapsedWidth,
            child: Center(
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  final isLight = themeState is LightTheme;
                  return IconButton(
                    onPressed: () {
                      context.read<ThemeBloc>().add(
                        ChangeThemeEvent(
                          themeMode: isLight ? ThemeMode.dark : ThemeMode.light,
                        ),
                      );
                    },
                    icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
                    tooltip: isLight ? 'Dunkel' : 'Hell',
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}