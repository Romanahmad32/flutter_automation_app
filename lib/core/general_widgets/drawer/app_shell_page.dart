// import 'package:auto_route/auto_route.dart';
// import 'package:automation_app/core/router/app_router.gr.dart';
// import 'package:automation_app/core/theme/presentation/bloc/theme_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// @RoutePage()
// class AppShellPage extends StatefulWidget {
//   const AppShellPage({super.key});
//
//   @override
//   State<AppShellPage> createState() => _AppShellPageState();
// }
//
// class _AppShellPageState extends State<AppShellPage> {
//   bool _isExtended = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return AutoTabsRouter(
//       routes: [WordAutomationRoute(), SettingsRoute()],
//       builder: (context, child) {
//         final tabsRouter = AutoTabsRouter.of(context);
//
//         return Scaffold(
//           body: Row(
//             children: [
//               NavigationRail(
//                 extended: _isExtended,
//                 leading: IconButton(
//                   onPressed: () {
//                     setState(() {
//                       _isExtended = !_isExtended;
//                     });
//                   },
//                   icon: const Icon(Icons.menu),
//                 ),
//                 trailingAtBottom: true,
//                 trailing: BlocBuilder<ThemeBloc, ThemeState>(
//                   builder: (context, themeState) {
//                     final isLight = themeState is LightTheme;
//
//                     return IconButton(
//                       onPressed: () {
//                         final newMode = isLight ? ThemeMode.dark : ThemeMode.light;
//                         context.read<ThemeBloc>().add(
//                           ChangeThemeEvent(themeMode: newMode),
//                         );
//                       },
//                       icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
//                     );
//                   },
//                 ),
//                 minExtendedWidth: 200,
//                 destinations: const [
//                   NavigationRailDestination(
//                     icon: Icon(Icons.document_scanner_outlined),
//                     selectedIcon: Icon(Icons.document_scanner),
//                     label: Text('Word Automation'),
//                   ),
//                   NavigationRailDestination(
//                     icon: Icon(Icons.settings_outlined),
//                     selectedIcon: Icon(Icons.settings),
//                     label: Text('Einstellungen'),
//                   ),
//                 ],
//                 selectedIndex: tabsRouter.activeIndex,
//                 onDestinationSelected: tabsRouter.setActiveIndex,
//               ),
//
//               Expanded(child: child),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/general_widgets/drawer/app_side_bar.dart';
import 'package:automation_app/core/router/app_router.gr.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  bool _isExtended = false;

  static const _collapsedWidth = 72.0;
  static const _expandedWidth = 220.0;
  static const _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [WordAutomationRoute(), SettingsRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: Row(
            children: [
              AppSidebar(
                isExtended: _isExtended,
                collapsedWidth: _collapsedWidth,
                expandedWidth: _expandedWidth,
                animationDuration: _animationDuration,
                activeIndex: tabsRouter.activeIndex,
                onDestinationSelected: tabsRouter.setActiveIndex,
                onToggle: () => setState(() => _isExtended = !_isExtended),
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}