part of 'document_bloc.dart';

sealed class DocumentEvent {
  const DocumentEvent();
}

final class DocumentSelectedEvent extends DocumentEvent {
  final String path;

  const DocumentSelectedEvent(this.path);
}

final class EditDocumentEvent extends DocumentEvent {
  final Map<String, String> data;

  const EditDocumentEvent({required this.data});
}

