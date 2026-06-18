part of 'zentralruf_reply_bloc.dart';

sealed class ZentralrufReplyEvent extends Equatable {
  const ZentralrufReplyEvent();

  @override
  List<Object?> get props => [];
}

class ParseZentralrufReplyEvent extends ZentralrufReplyEvent {
  final ZentralrufReplyInput input;

  const ParseZentralrufReplyEvent(this.input);

  @override
  List<Object?> get props => [input];
}
