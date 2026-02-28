import 'dart:async';

import 'package:automation_app/core/general_classes/usecases/use_case.dart';
import 'package:automation_app/features/word_automation/domain/usecases/fill_out_template.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'document_event.dart';

part 'document_state.dart';

@injectable
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final UseCase<String, FillOutTemplateParams> fillOutTemplate;

  DocumentBloc(this.fillOutTemplate) : super(DocumentInitial()) {
    on<DocumentSelectedEvent>(_onDocumentSelectedEvent);
    on<EditDocumentEvent>(_onEditDocumentEvent);
  }

  void _onDocumentSelectedEvent(
    DocumentSelectedEvent event,
    Emitter<DocumentState> emit,
  ) {
    emit(DocumentLoaded(event.path, null));
  }

  Future<void> _onEditDocumentEvent(
    EditDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    String? currentPath;

    if (state is DocumentLoaded) {
      currentPath = (state as DocumentLoaded).path;
    }
    if (currentPath == null || currentPath.isEmpty) {
      emit(const DocumentError('Kein Dokument geöffnet'));
      return;
    }

    final result = await fillOutTemplate(
      FillOutTemplateParams(path: currentPath, data: event.data),
    );

    switch (result) {
      case Left(value: final failure):
        emit(DocumentError(failure.message));
      case Right(value: final resultPath):
        emit(DocumentLoaded(currentPath, resultPath));
    }
  }
}
