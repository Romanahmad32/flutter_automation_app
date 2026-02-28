// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:automation_app/core/general_widgets/drawer/app_shell_page.dart'
    as _i1;
import 'package:automation_app/features/test_feature/presentation/pages/my_page.dart'
    as _i2;
import 'package:automation_app/features/word_automation/presentation/pages/word_automation_page.dart'
    as _i3;

/// generated route for
/// [_i1.AppShellPage]
class AppShellRoute extends _i4.PageRouteInfo<void> {
  const AppShellRoute({List<_i4.PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppShellPage();
    },
  );
}

/// generated route for
/// [_i2.MyPage]
class MyRoute extends _i4.PageRouteInfo<void> {
  const MyRoute({List<_i4.PageRouteInfo>? children})
    : super(MyRoute.name, initialChildren: children);

  static const String name = 'MyRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.MyPage();
    },
  );
}

/// generated route for
/// [_i3.WordAutomationPage]
class WordAutomationRoute extends _i4.PageRouteInfo<void> {
  const WordAutomationRoute({List<_i4.PageRouteInfo>? children})
    : super(WordAutomationRoute.name, initialChildren: children);

  static const String name = 'WordAutomationRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.WordAutomationPage();
    },
  );
}
