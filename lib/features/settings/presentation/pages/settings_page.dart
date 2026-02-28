import 'package:auto_route/auto_route.dart';
import 'package:automation_app/features/settings/presentation/views/app_settings_view.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SettingsPage extends StatelessWidget implements AutoRouteWrapper {
  SettingsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return this;
  }

  final List<Widget> _tabs = [
    Tab(icon: Icon(Icons.info), text: 'Allgemein'),
    Tab(icon: Icon(Icons.fourteen_mp_outlined), text: 'Zeit'),
    Tab(icon: Icon(Icons.history), text: 'Historie'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen'), centerTitle: true),
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            TabBar(tabs: _tabs),
            Expanded(
              child: TabBarView(
                children: [
                  AppSettingsView(),
                  Text('Settings'),
                  Text('History'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
