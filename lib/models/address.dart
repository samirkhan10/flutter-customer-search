class Address {
  final String id;
  final String type;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  const Address({
    required this.id,
    required this.type,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        type: json['type'] as String,
        street: json['street'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        zipCode: json['zipCode'] as String,
      );

  String get cityLine => '$city, $state $zipCode';
}
