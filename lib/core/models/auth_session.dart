import 'employee.dart';

class AuthSession {
  const AuthSession({required this.token, required this.employee});

  final String token;
  final Employee employee;
}
