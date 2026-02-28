import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class GeneralTextField<T> extends StatelessWidget {
  final String? labelText;
  final String? formControlName;
  final Map<String, String Function(Object)>? validationMessages;

  const GeneralTextField({
    super.key,
    this.labelText,
    this.formControlName,
    this.validationMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<T>(
      formControlName: formControlName,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      validationMessages: validationMessages,
    );
  }
}
