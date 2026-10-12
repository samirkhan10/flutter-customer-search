class Phone {
  final String id;
  final String type;
  final String number;
  final bool isPrimary;

  const Phone({
    required this.id,
    required this.type,
    required this.number,
    required this.isPrimary,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        id: json['id'] as String,
        type: json['type'] as String,
        number: json['number'] as String,
        isPrimary: json['isPrimary'] as bool? ?? false,
      );
}
