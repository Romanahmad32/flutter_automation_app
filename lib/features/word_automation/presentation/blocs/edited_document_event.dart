part of 'edited_document_bloc.dart';

sealed class EditedDocumentEvent extends Equatable {
  const EditedDocumentEvent();
}

final class EditDocumentEvent extends EditedDocumentEvent {
  final String path;
  final Map<String, String> data;

  const EditDocumentEvent({required this.data, required this.path});

  @override
  List<Object?> get props => [path, data];
}
