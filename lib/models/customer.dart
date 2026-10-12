import 'address.dart';
import 'email.dart';
import 'phone.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String maritalStatus;
  final String secureId;
  final List<Address> addresses;
  final List<Phone> phones;
  final List<Email> emails;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.secureId,
    required this.addresses,
    required this.phones,
    required this.emails,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        dateOfBirth: json['dateOfBirth'] as String,
        maritalStatus: json['maritalStatus'] as String? ?? '',
        secureId: json['secureId'] as String? ?? '',
        addresses: _list(json['addresses'], Address.fromJson),
        phones: _list(json['phones'], Phone.fromJson),
        emails: _list(json['emails'], Email.fromJson),
      );

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) {
    if (raw == null) return const [];
    return (raw as List).map((e) => parse(e as Map<String, dynamic>)).toList();
  }

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}';

  Phone? get primaryPhone =>
      phones.where((p) => p.isPrimary).firstOrNull ?? phones.firstOrNull;

  Email? get primaryEmail =>
      emails.where((e) => e.isPrimary).firstOrNull ?? emails.firstOrNull;

  /// Flat values the search can match against, keyed the same way as
  /// FieldConfig.key. A new search field only needs an entry here if it
  /// isn't already listed.
  Map<String, String> get searchableFields => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'maritalStatus': maritalStatus,
      };
}
