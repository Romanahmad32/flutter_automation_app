part of 'mailbox_config_bloc.dart';

sealed class MailboxConfigEvent extends Equatable {
  const MailboxConfigEvent();

  @override
  List<Object?> get props => [];
}

final class LoadMailboxConfigEvent extends MailboxConfigEvent {
  const LoadMailboxConfigEvent();
}

final class SaveMailboxConfigEvent extends MailboxConfigEvent {
  final MailboxConfigUpdate update;

  const SaveMailboxConfigEvent(this.update);

  @override
  List<Object?> get props => [update];
}
