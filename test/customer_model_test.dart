import 'dart:convert';

import 'package:care247_customer_search/models/customer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  final raw = jsonDecode(sampleCustomersJson) as List;

  test('parses a customer with nested addresses, phones and emails', () {
    final john = Customer.fromJson(raw.first as Map<String, dynamic>);

    expect(john.fullName, 'John Smith');
    expect(john.dateOfBirth, '1985-03-15');
    expect(john.addresses.single.city, 'San Francisco');
    expect(john.phones, hasLength(2));
    expect(john.emails.single.isPrimary, isTrue);
  });

  test('primaryPhone picks the one flagged primary, not just the first', () {
    final john = Customer.fromJson(raw.first as Map<String, dynamic>);
    expect(john.primaryPhone?.number, '+1-415-555-0199');
  });

  test('missing contact lists become empty lists', () {
    final c = Customer.fromJson({
      'id': 'x',
      'firstName': 'No',
      'lastName': 'Contacts',
      'dateOfBirth': '2000-01-01',
    });

    expect(c.addresses, isEmpty);
    expect(c.primaryPhone, isNull);
    expect(c.primaryEmail, isNull);
  });

  test('throws on a malformed record instead of producing junk', () {
    expect(() => Customer.fromJson({'id': 1}), throwsA(isA<TypeError>()));
  });
}
