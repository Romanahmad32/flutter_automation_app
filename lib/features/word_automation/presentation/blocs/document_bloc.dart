import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';

part 'document_event.dart';
part 'document_state.dart';

@injectable
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  DocumentBloc() : super(DocumentInitial()) {
    on<SelectDocumentEvent>(_onSelectDocumentEvent);
  }

  Future<void> _onSelectDocumentEvent(
    SelectDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result == null) {
      emit(DocumentError('Dokument konnte nicht geladen werden'));
    }
    emit(DocumentLoaded(path: result!.files.first.path!));
  }
}
