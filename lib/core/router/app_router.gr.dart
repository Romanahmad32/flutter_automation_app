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
import 'package:automation_app/features/settings/presentation/pages/settings_page.dart'
    as _i2;
import 'package:automation_app/features/word_automation/presentation/pages/word_automation_page.dart'
    as _i3;
import 'package:flutter/material.dart' as _i5;

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
/// [_i2.SettingsPage]
class SettingsRoute extends _i4.PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({_i5.Key? key, List<_i4.PageRouteInfo>? children})
    : super(
        SettingsRoute.name,
        args: SettingsRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'SettingsRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SettingsRouteArgs>(
        orElse: () => const SettingsRouteArgs(),
      );
      return _i4.WrappedRoute(child: _i2.SettingsPage(key: args.key));
    },
  );
}

class SettingsRouteArgs {
  const SettingsRouteArgs({this.key});

  final _i5.Key? key;

  @override
  String toString() {
    return 'SettingsRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SettingsRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
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
      return _i4.WrappedRoute(child: const _i3.WordAutomationPage());
    },
  );
}
