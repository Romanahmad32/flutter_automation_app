import 'package:automation_app/features/word_automation/presentation/blocs/document_bloc.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordTemplateDocumentView extends StatelessWidget {
  const WordTemplateDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          return switch (state) {
            DocumentInitial() => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Kein Dokument geöffnet')],
              ),
            ),
            DocumentLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DocumentLoaded() => DocxView.path(
              state.path,
              config: DocxViewConfig(
                enableZoom: false,
                pageMode: DocxPageMode.paged,
              ),
            ),
            DocumentError() => Center(
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
    );
  }
}
