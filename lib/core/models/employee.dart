import 'dart:convert';

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as String? ?? json['employee_id'] as String? ?? '',
        name: json['name'] as String? ?? 'Unknown',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  factory Employee.fromEncoded(String data) =>
      Employee.fromJson(jsonDecode(data) as Map<String, dynamic>);

  String encode() => jsonEncode(toJson());
}
