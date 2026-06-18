import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;
  UserRemoteDataSource({required this.apiClient});

  Future<User> getUser(String id) async {
    final data = await apiClient.get('/api/v1/users/$id');
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<User> updateUser(
    String id, {
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    final data = await apiClient.put(
      '/api/v1/users/$id',
      body: {'firstName': firstName, 'lastName': lastName, 'photoUrl': photoUrl},
    );
    // Si el backend devuelve 204 (body vacío) re-fetch; si devuelve el user, parsearlo.
    if (data is Map<String, dynamic>) return User.fromJson(data);
    return getUser(id);
  }

  Future<void> changePassword(
    String id, {
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.patch(
      '/api/v1/users/$id/password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}
