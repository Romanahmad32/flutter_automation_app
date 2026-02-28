import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/router/app_router.dart';
import 'package:automation_app/core/theme/presentation/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _router = getIt<AppRouter>();

  final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  );
  final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ThemeBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          ThemeMode themeMode;
          switch (state) {
            case DarkTheme():
              themeMode = ThemeMode.dark;
              break;
            case LightTheme():
              themeMode = ThemeMode.light;
              break;
            case SystemTheme():
              themeMode = ThemeMode.system;
              break;
          }
          return MaterialApp.router(
            routerConfig: _router.config(),
            themeMode: themeMode,
            darkTheme: darkTheme,
            theme: lightTheme,
          );
        },
      ),
    );
  }
}
