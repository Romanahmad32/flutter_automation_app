import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'app_router.gr.dart';
@singleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: AppShellRoute.page,
      children: [
        // These are the children injected into the Expanded(child: child) above
        AutoRoute(path: 'word-automation', page: WordAutomationRoute.page),
        AutoRoute(path: 'my', page: MyRoute.page),
      ],
    ),
  ];
}

