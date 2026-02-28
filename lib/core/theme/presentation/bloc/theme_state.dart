part of 'theme_bloc.dart';

@immutable
sealed class ThemeState {}

final class DarkTheme extends ThemeState {
  DarkTheme();
}

final class LightTheme extends ThemeState {
  LightTheme();
}

final class SystemTheme extends ThemeState {
  SystemTheme();
}
