part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

final class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  ChangeThemeEvent({required this.themeMode});
}
