part of 'edited_document_bloc.dart';

sealed class EditedDocumentState extends Equatable {
  const EditedDocumentState();

  @override
  List<Object> get props => [];
}

final class EditedDocumentInitial extends EditedDocumentState {}

final class EditedDocumentLoaded extends EditedDocumentState {
  final String path;

  const EditedDocumentLoaded(this.path);

  @override
  List<Object> get props => [path];
}

final class EditedDocumentError extends EditedDocumentState {
  final String message;

  const EditedDocumentError(this.message);

  @override
  List<Object> get props => [message];
}

final class EditedDocumentLoading extends EditedDocumentState {}
