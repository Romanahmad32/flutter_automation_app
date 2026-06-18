import 'package:automation_app/core/general_widgets/form/form_section.dart';
import 'package:automation_app/features/mailbox/domain/entities/mailbox_config.dart';
import 'package:automation_app/features/mailbox/presentation/blocs/mailbox_config_bloc/mailbox_config_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Einstellungsmaske für den Postfach-Zugang (REQUIREMENTS.md §3.3/§4). Mit
/// diesen Angaben überwacht das Backend das Postfach ereignisbasiert und erfasst
/// eingehende Zentralruf-Antworten selbsttätig. Für Gmail ist ein App-Passwort
/// bei aktivierter 2-Faktor-Authentifizierung nötig.
class MailboxAccessView extends StatefulWidget {
  const MailboxAccessView({super.key});

  @override
  State<MailboxAccessView> createState() => _MailboxAccessViewState();
}

class _MailboxAccessViewState extends State<MailboxAccessView>
    with AutomaticKeepAliveClientMixin {
  bool _initialized = false;

  // Liegt im selben TabBarView wie die Kanzleidaten. KeepAlive verhindert, dass
  // die TabBarView den State beim Tab-Wechsel verwirft und das Formular leer
  // neu aufbaut (der Listener würde sonst nicht erneut befüllen).
  @override
  bool get wantKeepAlive => true;

  /// Ob bereits ein App-Passwort gespeichert ist — dann darf das Feld leer
  /// bleiben (unverändert), und wir schicken kein null-überschreibendes Passwort.
  bool _appPasswordSet = false;

  final ScrollController _scrollController = ScrollController();

  final FormGroup _form = FormGroup({
    'enabled': FormControl<bool>(value: false),
    'host': FormControl<String>(
      value: 'imap.gmail.com',
      validators: [Validators.required],
    ),
    'port': FormControl<String>(
      value: '993',
      validators: [Validators.required, Validators.number()],
    ),
    'useSsl': FormControl<bool>(value: true),
    'username': FormControl<String>(validators: [Validators.email]),
    'appPassword': FormControl<String>(),
    'folder': FormControl<String>(
      value: 'INBOX',
      validators: [Validators.required],
    ),
    'subjectFilter': FormControl<String>(value: 'Zentralruf'),
  });

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _patch(MailboxConfig config) {
    _appPasswordSet = config.appPasswordSet;
    _form.patchValue({
      'enabled': config.enabled,
      'host': config.host,
      'port': config.port.toString(),
      'useSsl': config.useSsl,
      'username': config.username,
      // Das gespeicherte Passwort liefert das Backend nie aus; Feld bleibt leer.
      'appPassword': '',
      'folder': config.folder,
      'subjectFilter': config.subjectFilter,
    });
  }

  void _save() {
    final value = _form.value;
    String read(String key) => (value[key] as String?)?.trim() ?? '';

    final passwordInput = read('appPassword');
    // Leer + bereits gesetzt = unverändert lassen (null). Sonst neuer Wert.
    final String? appPassword = passwordInput.isEmpty
        ? (_appPasswordSet ? null : '')
        : passwordInput;

    context.read<MailboxConfigBloc>().add(
      SaveMailboxConfigEvent(
        MailboxConfigUpdate(
          enabled: (value['enabled'] as bool?) ?? false,
          host: read('host'),
          port: int.tryParse(read('port')) ?? 993,
          useSsl: (value['useSsl'] as bool?) ?? true,
          username: read('username'),
          appPassword: appPassword,
          folder: read('folder'),
          subjectFilter: read('subjectFilter'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    return BlocConsumer<MailboxConfigBloc, MailboxConfigState>(
      listener: (context, state) {
        if (state is MailboxConfigLoaded) {
          if (!_initialized) {
            _patch(state.config);
            setState(() => _initialized = true);
          } else {
            // Nach dem Speichern den "Passwort gesetzt"-Status aktualisieren.
            _appPasswordSet = state.config.appPasswordSet;
          }
          if (state.justSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Postfach-Zugang gespeichert. Die Überwachung verbindet sich '
                      'mit den neuen Werten neu.',
                ),
              ),
            );
          }
        } else if (state is MailboxConfigError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (!_initialized && state is MailboxConfigLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSaving = state is MailboxConfigLoading;

        return Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ReactiveForm(
                    formGroup: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        FormSection(
                          icon: Icons.mark_email_unread,
                          title: 'Postfach-Überwachung',
                          subtitle:
                          'Ist ein Zugang hinterlegt und die Überwachung '
                              'eingeschaltet, erfasst die App eingehende '
                              'Zentralruf-Antworten automatisch (erkannt über den '
                              'Betreff). Ohne Zugang bleibt sie inaktiv.',
                          children: const [_EnabledSwitch(), _SslSwitch()],
                        ),
                        FormSection(
                          icon: Icons.alternate_email,
                          title: 'Zugangsdaten',
                          subtitle:
                          'Für Gmail: 2-Faktor-Authentifizierung aktivieren '
                              'und unter myaccount.google.com/apppasswords ein '
                              'App-Passwort erzeugen — dieses, nicht das '
                              'Kontopasswort, gehört unten hinein.',
                          children: [
                            _field(
                              'username',
                              'Postfach-Adresse (E-Mail)',
                              keyboardType: TextInputType.emailAddress,
                              validationMessages: {
                                ValidationMessage.email: (_) =>
                                'Bitte eine gültige E-Mail-Adresse eingeben',
                              },
                            ),
                            _PasswordField(alreadySet: _appPasswordSet),
                          ],
                        ),
                        FormSection(
                          icon: Icons.dns,
                          title: 'Server (Standard: Gmail)',
                          subtitle:
                          'Für Gmail unverändert lassen. Andere Anbieter: '
                              'IMAP-Host, Port und Verschlüsselung anpassen.',
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _field(
                                    'host',
                                    'IMAP-Host',
                                    validationMessages: {
                                      ValidationMessage.required: (_) =>
                                      'Pflichtfeld',
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _field(
                                    'port',
                                    'Port',
                                    keyboardType: TextInputType.number,
                                    validationMessages: {
                                      ValidationMessage.required: (_) =>
                                      'Pflichtfeld',
                                      ValidationMessage.number: (_) => 'Zahl',
                                    },
                                  ),
                                ),
                              ],
                            ),
                            _field(
                              'folder',
                              'Ordner',
                              validationMessages: {
                                ValidationMessage.required: (_) =>
                                'Pflichtfeld',
                              },
                            ),
                            _field(
                              'subjectFilter',
                              'Betreff-Filter (leer = alle Mails prüfen)',
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ReactiveFormConsumer(
                            builder: (context, form, child) {
                              return FilledButton.icon(
                                icon: isSaving
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Icon(Icons.save),
                                label: const Text('Speichern'),
                                onPressed: (form.valid && !isSaving)
                                    ? _save
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(String controlName,
      String label, {
        TextInputType? keyboardType,
        Map<String, String Function(Object)>? validationMessages,
      }) {
    return ReactiveTextField<String>(
      formControlName: controlName,
      keyboardType: keyboardType,
      validationMessages: validationMessages,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Hauptschalter der Überwachung mit erklärendem Untertext.
class _EnabledSwitch extends StatelessWidget {
  const _EnabledSwitch();

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<bool>(
      formControlName: 'enabled',
      builder: (context, control, _) {
        final enabled = control.value ?? false;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: enabled,
          onChanged: (v) => control.value = v,
          title: const Text('Postfach automatisch überwachen'),
          subtitle: Text(
            enabled
                ? 'Eingehende Antworten werden automatisch erfasst.'
                : 'Die Überwachung ist ausgeschaltet.',
          ),
        );
      },
    );
  }
}

/// Schalter für SSL/TLS direkt beim Verbindungsaufbau (Port 993) vs. STARTTLS.
class _SslSwitch extends StatelessWidget {
  const _SslSwitch();

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<bool>(
      formControlName: 'useSsl',
      builder: (context, control, _) {
        final useSsl = control.value ?? true;
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: useSsl,
          onChanged: (v) => control.value = v,
          title: const Text('SSL/TLS direkt beim Verbinden (Port 993)'),
          subtitle: Text(
            useSsl
                ? 'Empfohlen für Gmail.'
                : 'STARTTLS wird verwendet, sofern der Server es anbietet.',
          ),
        );
      },
    );
  }
}

/// App-Passwort-Feld: obscured; ist bereits eines gespeichert, darf es leer
/// bleiben (dann wird das gespeicherte beibehalten).
class _PasswordField extends StatefulWidget {
  final bool alreadySet;

  const _PasswordField({required this.alreadySet});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<String>(
      formControlName: 'appPassword',
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: widget.alreadySet
            ? 'App-Passwort (gespeichert — leer lassen = unverändert)'
            : 'App-Passwort',
        helperText: widget.alreadySet
            ? 'Es ist bereits ein App-Passwort hinterlegt.'
            : 'Gmail-App-Passwort, nicht das Kontopasswort.',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
          tooltip: _obscured ? 'Anzeigen' : 'Verbergen',
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
