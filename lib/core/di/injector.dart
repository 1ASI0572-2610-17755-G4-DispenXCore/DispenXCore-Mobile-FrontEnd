import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/core/constants.dart';
import 'package:dispenxcore_frontend/core/storage/token_storage.dart';
import 'package:dispenxcore_frontend/core/storage/token_storage_impl.dart';
import 'package:dispenxcore_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dispenxcore_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/register_user.dart';
 
// Infraestructura base
final TokenStorage tokenStorage = TokenStorageImpl();
 
final ApiClient apiClient = ApiClient(
  baseUrl: BASE_URL,
  tokenStorage: tokenStorage,
);
 
// Auth
final AuthRemoteDataSource _authRemoteDataSource =
    AuthRemoteDataSource(apiClient: apiClient);
 
final AuthRepository authRepository = AuthRepositoryImpl(
  remoteDataSource: _authRemoteDataSource,
  tokenStorage: tokenStorage,
);
 
final LoginUser loginUserUseCase = LoginUser(authRepository);
final RegisterUser registerUserUseCase = RegisterUser(authRepository);
 
T injector<T>() {
  if (T == TokenStorage) return tokenStorage as T;
  if (T == ApiClient) return apiClient as T;
  if (T == AuthRepository) return authRepository as T;
  if (T == LoginUser) return loginUserUseCase as T;
  if (T == RegisterUser) return registerUserUseCase as T;
 
  throw Exception('Dependencia no registrada: $T');
}