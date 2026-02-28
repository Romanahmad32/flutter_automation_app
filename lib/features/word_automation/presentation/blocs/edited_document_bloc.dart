import 'dart:async';

import 'package:automation_app/core/general_classes/usecases/use_case.dart';
import 'package:automation_app/features/word_automation/domain/usecases/fill_out_template.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'edited_document_event.dart';

part 'edited_document_state.dart';

@injectable
class EditedDocumentBloc
    extends Bloc<EditedDocumentEvent, EditedDocumentState> {
  final UseCase<String, FillOutTemplateParams> fillOutTemplate;

  EditedDocumentBloc(this.fillOutTemplate) : super(EditedDocumentInitial()) {
    on<EditDocumentEvent>(_onEditDocumentEvent);
  }
  Future<void> _onEditDocumentEvent(
      EditDocumentEvent event,
      Emitter<EditedDocumentState> emit,
      ) async {

    emit(EditedDocumentLoading());

    if (event.path.isEmpty) {
      emit(const EditedDocumentError('Keine Vorlage geöffnet'));
      return;
    }

    final result = await fillOutTemplate(
      FillOutTemplateParams(path: event.path, data: event.data),
    );

    switch (result) {
      case Left(value: final failure):
        emit(EditedDocumentError(failure.message));
      case Right(value: final resultPath):
        emit(EditedDocumentLoaded(resultPath));
    }
  }


}
