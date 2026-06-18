part of 'mailbox_config_bloc.dart';

sealed class MailboxConfigState extends Equatable {
  const MailboxConfigState();

  @override
  List<Object?> get props => [];
}

final class MailboxConfigLoading extends MailboxConfigState {
  const MailboxConfigLoading();
}

final class MailboxConfigLoaded extends MailboxConfigState {
  final MailboxConfig config;

  /// True direkt nach erfolgreichem Speichern (für eine Bestätigungsmeldung).
  final bool justSaved;

  const MailboxConfigLoaded(this.config, {this.justSaved = false});

  @override
  List<Object?> get props => [config, justSaved];
}

final class MailboxConfigError extends MailboxConfigState {
  final String message;

  const MailboxConfigError(this.message);

  @override
  List<Object?> get props => [message];
}
