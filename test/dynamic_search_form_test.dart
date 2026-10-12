import 'package:care247_customer_search/config/search_config.dart';
import 'package:care247_customer_search/widgets/dynamic_search_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  testWidgets('renders configured fields in renderOrder', (tester) async {
    final shuffled = [searchConfig[2], searchConfig[0], searchConfig[1]];
    await tester.pumpWidget(wrap(DynamicSearchForm(fields: shuffled, onSearch: (_) {})));

    final labels = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((f) => f.decoration?.labelText)
        .toList();

    expect(labels, ['First Name', 'Last Name', 'Date of Birth']);
  });

  testWidgets('a new config entry shows up and is submitted without code changes',
      (tester) async {
    const fields = [
      ...searchConfig,
      FieldConfig(
        key: 'maritalStatus',
        type: FieldType.text,
        label: 'Marital Status',
        placeholder: 'e.g. Married',
        renderOrder: 4,
      ),
    ];
    Map<String, String>? submitted;

    await tester.pumpWidget(wrap(DynamicSearchForm(
      fields: fields,
      onSearch: (values) => submitted = values,
    )));

    await tester.enterText(find.widgetWithText(TextField, 'First Name'), ' John ');
    await tester.enterText(find.widgetWithText(TextField, 'Marital Status'), 'Married');
    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(submitted, {
      'firstName': 'John',
      'lastName': '',
      'dateOfBirth': '',
      'maritalStatus': 'Married',
    });
  });

  testWidgets('clear empties every field and calls onClear', (tester) async {
    var cleared = false;
    await tester.pumpWidget(wrap(DynamicSearchForm(
      fields: searchConfig,
      onSearch: (_) {},
      onClear: () => cleared = true,
    )));

    await tester.enterText(find.widgetWithText(TextField, 'Last Name'), 'Chen');
    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(find.text('Chen'), findsNothing);
    expect(cleared, isTrue);
  });
}
