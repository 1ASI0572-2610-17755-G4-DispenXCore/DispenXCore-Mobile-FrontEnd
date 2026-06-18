import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/users/domain/repositories/user_repository.dart';

class UpdateUser {
  final UserRepository repository;
  UpdateUser(this.repository);

  Future<User> call(
    String id, {
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) =>
      repository.updateUser(id, firstName: firstName, lastName: lastName, photoUrl: photoUrl);
}
