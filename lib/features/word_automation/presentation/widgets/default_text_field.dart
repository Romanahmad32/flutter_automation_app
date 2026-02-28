import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class DefaultTextField<T> extends StatelessWidget {
  final String? formControlName;
  final String? labelText;
  final Map<String, String Function(Object)>? validationMessages;
  final void Function(FormControl<T>)? onChanged;
  final ControlValueAccessor<T, String>? valueAccessor;

  const DefaultTextField({
    super.key,
    this.formControlName,
    this.labelText,
    this.validationMessages,
    this.onChanged,
    this.valueAccessor,
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
      onChanged: onChanged,
      validationMessages: validationMessages,
      valueAccessor: valueAccessor,
    );
  }
}
