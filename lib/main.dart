import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/router/app_router.dart';
import 'package:automation_app/core/theme/presentation/bloc/theme_bloc.dart';
import 'package:automation_app/core/theme/presentation/theme.dart';
import 'package:automation_app/core/theme/presentation/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt.allReady();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _router = getIt<AppRouter>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, 'Inter', 'Inter');
    MaterialTheme theme = MaterialTheme(textTheme);
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => getIt<ThemeBloc>())],
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
            debugShowCheckedModeBanner: false,
            routerConfig: _router.config(),
            themeMode: themeMode,
            darkTheme: theme.dark(),
            theme: theme.light(),
            // Deutsche Texte für Material-Dialoge (z. B. den Datums-Picker).
            locale: const Locale('de'),
            supportedLocales: const [Locale('de')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
