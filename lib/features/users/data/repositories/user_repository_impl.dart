import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/users/data/datasources/user_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getUser(String id) => remoteDataSource.getUser(id);

  @override
  Future<User> updateUser(
    String id, {
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) =>
      remoteDataSource.updateUser(id, firstName: firstName, lastName: lastName, photoUrl: photoUrl);

  @override
  Future<void> changePassword(
    String id, {
    required String currentPassword,
    required String newPassword,
  }) =>
      remoteDataSource.changePassword(id, currentPassword: currentPassword, newPassword: newPassword);
}
