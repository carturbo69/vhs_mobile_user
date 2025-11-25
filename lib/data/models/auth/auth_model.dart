// lib/data/models/auth_models.dart
class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class RegisterRequest {
  final String username;
  final String password;
  final String email;
  RegisterRequest({required this.username, required this.password, required this.email});
  Map<String, dynamic> toJson() => {'username': username, 'password': password, 'email': email};
}

class LoginRespond {
  final String token;
  final String role;
  final String accountId;
  LoginRespond({required this.token, required this.role, required this.accountId});
  factory LoginRespond.fromJson(Map<String, dynamic> j) {
    return LoginRespond(
      token: j['token'] ?? j['Token'] ?? '',
      role: j['role'] ?? j['Role'] ?? '',
      accountId: (j['accountId'] ?? j['AccountID'] ?? '').toString(),
    );
  }
}
