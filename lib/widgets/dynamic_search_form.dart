import 'package:flutter/material.dart';

import '../config/search_config.dart';
import 'dynamic_field.dart';

class DynamicSearchForm extends StatefulWidget {
  const DynamicSearchForm({
    super.key,
    required this.fields,
    required this.onSearch,
    this.onClear,
  });

  final List<FieldConfig> fields;

  /// Called with { field key: entered value } for every configured field.
  final ValueChanged<Map<String, String>> onSearch;
  final VoidCallback? onClear;

  @override
  State<DynamicSearchForm> createState() => _DynamicSearchFormState();
}

class _DynamicSearchFormState extends State<DynamicSearchForm> {
  late final List<FieldConfig> _fields;
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _fields = [...widget.fields]..sort((a, b) => a.renderOrder.compareTo(b.renderOrder));
    _controllers = {for (final f in _fields) f.key: TextEditingController()};
    _focusNodes = {for (final f in _fields) f.key: FocusNode()};
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onSearch({
      for (final entry in _controllers.entries) entry.key: entry.value.text.trim(),
    });
  }

  void _clear() {
    for (final c in _controllers.values) {
      c.clear();
    }
    FocusScope.of(context).unfocus();
    widget.onClear?.call();
  }

  void _goNext(int index) {
    if (index + 1 < _fields.length) {
      _focusNodes[_fields[index + 1].key]!.requestFocus();
    } else {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastIndex = _fields.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _fields.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DynamicField(
              key: ValueKey(_fields[i].key),
              config: _fields[i],
              controller: _controllers[_fields[i].key]!,
              focusNode: _focusNodes[_fields[i].key]!,
              textInputAction: i == lastIndex ? TextInputAction.search : TextInputAction.next,
              onSubmitted: () => _goNext(i),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.search),
          label: const Text('Search'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _clear,
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
