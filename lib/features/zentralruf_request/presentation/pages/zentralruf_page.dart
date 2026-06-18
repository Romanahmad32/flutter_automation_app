import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/core/general_widgets/page_refresh/page_refresh_scope.dart';
import 'package:automation_app/features/zentralruf_request/presentation/blocs/zentralruf_bloc.dart';
import 'package:automation_app/features/zentralruf_request/presentation/views/zentralruf_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ZentralrufPage extends StatelessWidget implements AutoRouteWrapper {
  const ZentralrufPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return PageRefreshScope(
      builder: (context) => BlocProvider(
        create: (context) =>
            getIt<ZentralrufBloc>()..add(const LoadZentralrufDefaultsEvent()),
        child: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ZentralrufBloc, ZentralrufState>(
      listener: (context, state) {
        if (state is ZentralrufError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              // Lang genug, um die Hinweise in Ruhe zu lesen.
              duration: const Duration(seconds: 8),
            ),
          );
        }
        if (state is ZentralrufPrefillSuccess) {
          final messenger = ScaffoldMessenger.of(context);
          final basis =
              'Formular vorausgefüllt (Referenz ${state.result.referenz}). '
              'Bitte Captcha im Browserfenster lösen und absenden.';

          if (state.auftragsnummerErhoehtAuf != null) {
            // Automatik-Modus: Nummer wurde bereits hochgezählt.
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  '$basis\nAuftragsnummer auf '
                  '${state.auftragsnummerErhoehtAuf} erhöht.',
                ),
                duration: const Duration(seconds: 6),
              ),
            );
          } else if (state.auftragsnummerVorschlag != null) {
            // Halbautomatik: Erhöhung dem Anwalt zur Bestätigung anbieten.
            final naechste = state.auftragsnummerVorschlag!;
            // Bloc vor dem async gap auflösen (context nach await unsicher).
            final bloc = context.read<ZentralrufBloc>();
            messenger.showSnackBar(
              SnackBar(
                content: Text(basis),
                duration: const Duration(seconds: 10),
                action: SnackBarAction(
                  label: 'Auftragsnr. → $naechste',
                  onPressed: () =>
                      bloc.add(ErhoeheAuftragsnummerEvent(naechste)),
                ),
              ),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text(basis),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
        if (state is ZentralrufAuftragsnummerErhoeht) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auftragsnummer auf ${state.neueNummer} erhöht.'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Zentralruf-Anfrage',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: const [PageRefreshButton()],
        ),
        body: const ZentralrufFormView(),
      ),
    );
  }
}
