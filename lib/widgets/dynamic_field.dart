import 'package:flutter/material.dart';

import '../config/search_config.dart';
import '../utils/dates.dart';

/// Renders one search input based on its [FieldConfig]. The form never needs
/// to know which field it is dealing with, only its type.
class DynamicField extends StatelessWidget {
  const DynamicField({
    super.key,
    required this.config,
    required this.controller,
    required this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final FieldConfig config;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return switch (config.type) {
      FieldType.text => TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: config.label,
            hintText: config.placeholder,
          ),
          onSubmitted: (_) => onSubmitted?.call(),
        ),
      FieldType.date => _DateField(
          config: config,
          controller: controller,
          focusNode: focusNode,
        ),
    };
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.config,
    required this.controller,
    required this.focusNode,
  });

  final FieldConfig config;
  final TextEditingController controller;
  final FocusNode focusNode;

  Future<void> _pickDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: config.label,
    );
    if (picked == null || !context.mounted) return;
    controller.text = toIsoDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: true,
        decoration: InputDecoration(
          labelText: config.label,
          hintText: config.placeholder,
          suffixIcon: value.text.isEmpty
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  tooltip: 'Clear ${config.label}',
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clear,
                ),
        ),
        onTap: () => _pickDate(context),
      ),
    );
  }
}
