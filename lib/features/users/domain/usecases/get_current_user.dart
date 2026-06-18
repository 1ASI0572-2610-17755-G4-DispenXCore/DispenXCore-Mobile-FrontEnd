import 'package:dispenxcore_frontend/core/storage/token_storage.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/users/domain/repositories/user_repository.dart';

class GetCurrentUser {
  final UserRepository repository;
  final TokenStorage tokenStorage;

  GetCurrentUser(this.repository, this.tokenStorage);

  Future<User> call() async {
    final id = await tokenStorage.getUserId();
    if (id == null || id.isEmpty) throw Exception('Usuario no autenticado.');
    return repository.getUser(id);
  }
}
