import 'package:automation_app/features/word_automation/presentation/blocs/document_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/edited_document_bloc.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordEditedDocumentView extends StatelessWidget {
  const WordEditedDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
        },
        child: BlocBuilder<EditedDocumentBloc, EditedDocumentState>(
          builder: (context, state) {
            return switch (state) {
              EditedDocumentInitial() => const Center(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Noch kein dokument ausgefüllt')],
                  ),
                ),
              ),
              EditedDocumentLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              EditedDocumentLoaded() => DocxView.path(
                state.path,
                config: DocxViewConfig(
                  enableZoom: false,
                  pageMode: DocxPageMode.paged,
                ),
              ),
              EditedDocumentError() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.yellow, size: 80),
                    SizedBox(height: 16),
                    Text(state.message),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}
