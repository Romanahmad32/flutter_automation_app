import 'package:auto_route/auto_route.dart';
import 'package:automation_app/core/di/injection.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/document_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/blocs/edited_document_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/views/word_edited_document_view.dart';
import 'package:automation_app/features/word_automation/presentation/views/word_form_view.dart';
import 'package:automation_app/features/word_automation/presentation/views/word_template_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class WordAutomationPage extends StatelessWidget implements AutoRouteWrapper {
  const WordAutomationPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<DocumentBloc>()),
        BlocProvider(create: (context) => getIt<EditedDocumentBloc>()),
      ],
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Word Vorlagen ausfüllen'),
          backgroundColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
        ),
        body: const Row(
          children: [
            WordFormView(),
            WordTemplateDocumentView(),
            WordEditedDocumentView(),
          ],
        ),
      ),
    );
  }
}
