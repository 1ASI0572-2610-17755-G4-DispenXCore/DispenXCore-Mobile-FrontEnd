import 'dart:convert';
import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/session.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
 
class AuthRemoteDataSource {
  final ApiClient apiClient;
 
  AuthRemoteDataSource({required this.apiClient});
 
  /// Mock: GET /users, filtra por email+password en cliente,
  /// genera token igual que el web (btoa equivalente en Dart).
  /// Cuando haya backend real, reemplazar por POST /auth/sign-in.
  Future<Session> login(String email, String password) async {
    final List<dynamic> users = await apiClient.get('/users', requiresAuth: false);
 
    final match = users.cast<Map<String, dynamic>>().firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );
 
    if (match.isEmpty) {
      throw Exception('Credenciales incorrectas.');
    }
 
    final user = User.fromJson(match);
 
    // Genera token igual que el web: base64(email:role:timestamp)
    final raw = '${user.email}:${user.role.name.toUpperCase()}:${DateTime.now().millisecondsSinceEpoch}';
    final token = base64Encode(utf8.encode(raw));
 
    return Session(token: token, user: user);
  }
 
  /// Mock: POST /users con role USER y status ACTIVE por defecto.
  /// Cuando haya backend real, reemplazar por POST /auth/sign-up.
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await apiClient.post(
      '/users',
      body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': 'USER',
        'status': 'ACTIVE',
      },
      requiresAuth: false,
    );
 
    return User.fromJson(response);
  }
}