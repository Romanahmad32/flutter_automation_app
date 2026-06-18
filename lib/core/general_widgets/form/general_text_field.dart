import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class GeneralTextField<T> extends StatelessWidget {
  final String? labelText;
  final String? formControlName;
  final InputDecoration? inputDecoration;
  final Map<String, String Function(Object)>? validationMessages;

  const GeneralTextField({
    super.key,
    this.labelText,
    this.formControlName,
    this.inputDecoration,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ReactiveTextField<T>(
      formControlName: formControlName,
      decoration: (inputDecoration ?? const InputDecoration()).copyWith(
        labelText: labelText ?? '',
        border: theme.inputDecorationTheme.border ?? const OutlineInputBorder(),
      ),
      validationMessages: validationMessages,
    );
  }
}
