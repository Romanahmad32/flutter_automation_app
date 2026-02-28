part of 'edited_document_bloc.dart';


sealed class EditedDocumentEvent extends Equatable {
  const EditedDocumentEvent();
}

class EditedDocumentReceived extends EditedDocumentEvent {
  final String path;

  const EditedDocumentReceived(this.path);

  @override
  List<Object?> get props => [path];
}
class ResetEditedDocumentView extends EditedDocumentEvent {
  const ResetEditedDocumentView();

  @override
  List<Object?> get props => [];
}