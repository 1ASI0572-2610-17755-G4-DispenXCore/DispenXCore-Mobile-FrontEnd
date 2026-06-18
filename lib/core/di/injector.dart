import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/core/constants.dart';
import 'package:dispenxcore_frontend/core/storage/token_storage.dart';
import 'package:dispenxcore_frontend/core/storage/token_storage_impl.dart';
import 'package:dispenxcore_frontend/features/alerts/data/datasources/alerts_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/alerts/data/repositories/alerts_repository_impl.dart';
import 'package:dispenxcore_frontend/features/alerts/domain/repositories/alerts_repository.dart';
import 'package:dispenxcore_frontend/features/alerts/domain/usecases/get_active_alerts.dart';
import 'package:dispenxcore_frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dispenxcore_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/register_user.dart';
import 'package:dispenxcore_frontend/features/users/data/datasources/user_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/users/data/repositories/user_repository_impl.dart';
import 'package:dispenxcore_frontend/features/users/domain/repositories/user_repository.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/change_password.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/get_current_user.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/update_user.dart';

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

// Alerts
final AlertsRemoteDataSource remoteDataSource =
    AlertsRemoteDataSourceImpl(apiClient: apiClient);

final AlertsRepository alertsRepository =
    AlertsRepositoryImpl(remoteDataSource: remoteDataSource);

// Users
final UserRemoteDataSource _userRemoteDataSource =
    UserRemoteDataSource(apiClient: apiClient);

final UserRepository userRepository =
    UserRepositoryImpl(remoteDataSource: _userRemoteDataSource);

// Use cases
final LoginUser loginUserUseCase = LoginUser(authRepository);
final RegisterUser registerUserUseCase = RegisterUser(authRepository);
final GetActiveAlerts getActiveAlertsUseCase = GetActiveAlerts(alertsRepository);
final GetCurrentUser getCurrentUserUseCase =
    GetCurrentUser(userRepository, tokenStorage);
final UpdateUser updateUserUseCase = UpdateUser(userRepository);
final ChangePassword changePasswordUseCase = ChangePassword(userRepository);

T injector<T>() {
  if (T == TokenStorage) return tokenStorage as T;
  if (T == ApiClient) return apiClient as T;
  if (T == AuthRepository) return authRepository as T;
  if (T == LoginUser) return loginUserUseCase as T;
  if (T == RegisterUser) return registerUserUseCase as T;
  if (T == AlertsRepository) return alertsRepository as T;
  if (T == GetActiveAlerts) return getActiveAlertsUseCase as T;
  if (T == UserRepository) return userRepository as T;
  if (T == GetCurrentUser) return getCurrentUserUseCase as T;
  if (T == UpdateUser) return updateUserUseCase as T;
  if (T == ChangePassword) return changePasswordUseCase as T;

  throw Exception('Dependencia no registrada: $T');
}
