import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@singleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(SystemTheme()) {
    on<ChangeThemeEvent>(_onChangeThemeEvent);
  }

  void _onChangeThemeEvent(ChangeThemeEvent event, Emitter<ThemeState> emit) {
    switch (event.themeMode){
      case ThemeMode.dark:
        emit(DarkTheme());
        break;
      case ThemeMode.light:
        emit(LightTheme());
        break;
      case ThemeMode.system:
        emit(SystemTheme());
        break;
    }
  }
}
