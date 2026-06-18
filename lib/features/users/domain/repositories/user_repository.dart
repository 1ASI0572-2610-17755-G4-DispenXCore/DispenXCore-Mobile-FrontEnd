import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String id);

  Future<User> updateUser(
    String id, {
    required String firstName,
    required String lastName,
    String? photoUrl,
  });

  Future<void> changePassword(
    String id, {
    required String currentPassword,
    required String newPassword,
  });
}
