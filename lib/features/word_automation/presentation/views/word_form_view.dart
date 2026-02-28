import 'package:automation_app/features/word_automation/presentation/blocs/document_bloc.dart'
    show DocumentBloc, DocumentSelectedEvent, DocumentState, DocumentLoaded, SelectDocumentEvent;
import 'package:automation_app/features/word_automation/presentation/blocs/edited_document_bloc.dart';
import 'package:automation_app/features/word_automation/presentation/widgets/default_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class WordFormView extends StatefulWidget {
  const WordFormView({super.key});

  @override
  State<WordFormView> createState() => _WordFormViewState();
}

class _WordFormViewState extends State<WordFormView> {
  final FormGroup formGroup = FormGroup({
    'firstName': FormControl<String>(),
    'lastName': FormControl<String>(),
    'age': FormControl<int>(
      validators: [
        Validators.number(allowNegatives: false, allowedDecimals: 0),
      ],
    ),
    'email': FormControl<String>(
      validators: [Validators.email, Validators.required],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final documentBloc = context.read<DocumentBloc>();
    final editedDocumentBloc = context.read<EditedDocumentBloc>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ReactiveForm(
            formGroup: formGroup,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    documentBloc.add(SelectDocumentEvent());
                  },
                  icon: const Icon(Icons.file_open),
                  label: const Text('Word-Dokument auswählen'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  'Formulardaten',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: DefaultTextField<String>(
                        formControlName: 'firstName',
                        labelText: 'Vorname',
                      ),
                    ),
                    Expanded(
                      child: DefaultTextField<String>(
                        formControlName: 'lastName',
                        labelText: 'Nachname',
                      ),
                    ),
                  ],
                ),
                DefaultTextField<int>(
                  formControlName: 'age',
                  labelText: 'Alter',
                  validationMessages: {
                    ValidationMessage.number: (error) => 'Ungültiges Alter',
                  },
                  valueAccessor: IntValueAccessor(),
                ),
                DefaultTextField<String>(
                  formControlName: 'email',
                  labelText: 'E-Mail',
                  validationMessages: {
                    ValidationMessage.email: (error) => 'Ungültige E-Mail',
                    ValidationMessage.required: (error) =>
                        'E-Mail ist ein Pflichtfeld',
                  },
                ),
                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return BlocProvider.value(
                      value: documentBloc,
                      child: BlocBuilder<DocumentBloc, DocumentState>(
                        builder: (context, state) {
                          return FilledButton.icon(
                            onPressed: form.valid
                                ? () => editedDocumentBloc.add(
                                    EditDocumentEvent(
                                      data: {
                                        'firstName':
                                            formGroup
                                                .control('firstName')
                                                .value ??
                                            '',
                                        'lastName':
                                            formGroup
                                                .control('lastName')
                                                .value ??
                                            '',
                                        'age':
                                            formGroup
                                                .control('age')
                                                .value
                                                ?.toString() ??
                                            '',
                                        'email':
                                            formGroup.control('email').value ??
                                            '',
                                      },
                                      path: state is DocumentLoaded
                                          ? state.path
                                          : '',
                                    ),
                                  )
                                : null,
                            label: const Text('Word-Dokument bearbeiten'),
                            icon: const Icon(Icons.edit),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
