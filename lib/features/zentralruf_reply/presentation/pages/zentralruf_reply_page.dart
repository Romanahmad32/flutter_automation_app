import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/general_widgets/page_refresh/page_refresh_scope.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/blocs/zentralruf_reply_bloc.dart';
import 'package:automation_app/features/zentralruf_reply/presentation/views/zentralruf_reply_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Schritt 3 des Workflows (REQUIREMENTS.md §3.3): Die per E-Mail eingegangene
/// Zentralruf-Antwort wird eingefügt bzw. als Datei geladen, die App
/// extrahiert die Versicherungsdaten und merkt sie für die Vorlagenausfüllung.
@RoutePage()
class ZentralrufReplyPage extends StatelessWidget implements AutoRouteWrapper {
  const ZentralrufReplyPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return PageRefreshScope(
      builder: (context) => BlocProvider(
        create: (context) => getIt<ZentralrufReplyBloc>(),
        child: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZentralrufReplyBloc, ZentralrufReplyState>(
      listener: (context, state) {
        if (state is ZentralrufReplyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Zentralruf-Antwort',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: const [PageRefreshButton()],
        ),
        body: const ZentralrufReplyView(),
      ),
    );
  }
}
