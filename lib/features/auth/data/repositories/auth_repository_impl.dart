import 'package:dispenxcore_frontend/core/storage/token_storage.dart';
import 'package:dispenxcore_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/auth/domain/entities/session.dart';
import 'package:dispenxcore_frontend/features/auth/domain/repositories/auth_repository.dart';
 
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
 
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });
 
  @override
  Future<Session> login(String email, String password) async {
    final session = await remoteDataSource.login(email, password);
 
    // Persiste los datos relevantes para la app
    await tokenStorage.saveToken(session.token);
    await tokenStorage.saveUserId(session.user.id.toString());
    await tokenStorage.saveRole(session.user.role.name.toUpperCase());
    await tokenStorage.saveStatus(session.user.status.name.toUpperCase());
 
    return session;
  }
 
  @override
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return remoteDataSource.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}