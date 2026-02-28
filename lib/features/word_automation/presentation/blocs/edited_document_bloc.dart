import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'edited_document_event.dart';

part 'edited_document_state.dart';

@injectable
class EditedDocumentBloc
    extends Bloc<EditedDocumentEvent, EditedDocumentState> {
  EditedDocumentBloc() : super(EditedDocumentInitial()) {
    on<EditedDocumentReceived>(_onEditedDocumentReceived);
    on<ResetEditedDocumentView>(_onResetEditedDocumentView);
  }

  void _onEditedDocumentReceived(
    EditedDocumentReceived event,
    Emitter<EditedDocumentState> emit,
  ) {
    emit(EditedDocumentLoaded(event.path));
  }

  void _onResetEditedDocumentView(
    ResetEditedDocumentView event,
    Emitter<EditedDocumentState> emit,
  ) {
    emit(EditedDocumentInitial());
  }
}
