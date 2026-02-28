import 'package:auto_route/auto_route.dart';
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
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [WordAutomationRoute(), MyRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: _isExtended,
                leading: IconButton(
                  onPressed: () {
                    setState(() {
                      _isExtended = !_isExtended;
                    });
                  },
                  icon:  Icon(_isExtended ? Icons.menu_open: Icons.menu),
                ),
                minExtendedWidth: 200,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.document_scanner_outlined),
                    selectedIcon: Icon(Icons.document_scanner),
                    label: Text('Word Automation'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle),
                    label: Text('Word Automation'),
                  ),
                ],
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: tabsRouter.setActiveIndex,
              ),
              const VerticalDivider(thickness: 1, width: 1),

              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
