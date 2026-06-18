import 'package:flutter/foundation.dart';
import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/session.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Session> login(String email, String password) async {
    final response = await apiClient.post(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    // TEMPORAL — remover antes de producción
    debugPrint('[AUTH] login response: $response');

    final token = response['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Respuesta inesperada del servidor (token ausente).');
    }

    final userJson = response['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw Exception('Respuesta inesperada del servidor (user ausente).');
    }

    return Session(token: token, user: User.fromJson(userJson));
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await apiClient.post(
      '/api/v1/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    // TEMPORAL — remover antes de producción
    debugPrint('[AUTH] register response: $response');
    // El backend devuelve { "message": "..." } — nada más que parsear.
  }

  Future<void> logout() async {
    await apiClient.post('/api/v1/auth/logout', requiresAuth: true);
  }
}
