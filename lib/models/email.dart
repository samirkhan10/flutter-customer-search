class Email {
  final String id;
  final String type;
  final String address;
  final bool isPrimary;

  const Email({
    required this.id,
    required this.type,
    required this.address,
    required this.isPrimary,
  });

  factory Email.fromJson(Map<String, dynamic> json) => Email(
        id: json['id'] as String,
        type: json['type'] as String,
        address: json['address'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
      );
}
