import 'package:automation_app/features/form_template_setup/domain/entities/input_type.dart';

class FieldData {
  final int order;
  final String label;
  final bool required;
  final InputType inputType;

  const FieldData({
    required this.order,
    required this.label,
    required this.required,
    required this.inputType,
  });

  FieldData copyWith({
    int? order,
    String? label,
    bool? required,
    InputType? inputType,
  }) {
    return FieldData(
      order: order ?? this.order,
      label: label ?? this.label,
      required: required ?? this.required,
      inputType: inputType ?? this.inputType,
    );
  }

  factory FieldData.fromJson(Map<String, dynamic> json) {
    return FieldData(
      order: json['order'],
      label: json['label'],
      required: json['required'],
      inputType: InputType.fromValue(json['inputType']),
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'order': order,
        'label': label,
        'required': required,
        'inputType': inputType.value,
      };
}
