import 'package:dispenxcore_frontend/features/users/domain/repositories/user_repository.dart';

class ChangePassword {
  final UserRepository repository;
  ChangePassword(this.repository);

  Future<void> call(
    String id, {
    required String currentPassword,
    required String newPassword,
  }) =>
      repository.changePassword(id, currentPassword: currentPassword, newPassword: newPassword);
}
