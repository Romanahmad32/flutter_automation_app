part of 'document_bloc.dart';

sealed class DocumentEvent {
  const DocumentEvent();
}

final class SelectDocumentEvent extends DocumentEvent {
  const SelectDocumentEvent();
}
