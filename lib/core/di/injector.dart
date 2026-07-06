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
import 'package:dispenxcore_frontend/features/device/data/datasources/device_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/device/data/repositories/device_repository_impl.dart';
import 'package:dispenxcore_frontend/features/device/domain/repositories/device_repository.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/get_device.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/ping_device.dart';
import 'package:dispenxcore_frontend/features/device/domain/usecases/update_device.dart';
import 'package:dispenxcore_frontend/features/dispensators/data/datasources/dispensator_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/dispensators/data/repositories/dispensator_repository_impl.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/repositories/dispensator_repository.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/usecases/get_dispensator_detail.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/usecases/get_dispensators.dart';
import 'package:dispenxcore_frontend/features/users/data/datasources/user_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/users/data/repositories/user_repository_impl.dart';
import 'package:dispenxcore_frontend/features/users/domain/repositories/user_repository.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/change_password.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/get_current_user.dart';
import 'package:dispenxcore_frontend/features/alertas_stock/data/datasources/alertas_stock_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/alertas_stock/data/repositories/alertas_stock_repository_impl.dart';
import 'package:dispenxcore_frontend/features/alertas_stock/domain/repositories/alertas_stock_repository.dart';
import 'package:dispenxcore_frontend/features/alertas_stock/domain/usecases/alertas_stock_usecases.dart';
import 'package:dispenxcore_frontend/features/history/data/datasources/history_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/inventario/data/datasources/inventario_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/inventario/data/repositories/inventario_repository_impl.dart';
import 'package:dispenxcore_frontend/features/inventario/domain/repositories/inventario_repository.dart';
import 'package:dispenxcore_frontend/features/inventario/domain/usecases/inventario_usecases.dart';
import 'package:dispenxcore_frontend/features/history/data/repositories/history_repository_impl.dart';
import 'package:dispenxcore_frontend/features/history/domain/repositories/history_repository.dart';
import 'package:dispenxcore_frontend/features/history/domain/usecases/get_dispenser_events.dart';
import 'package:dispenxcore_frontend/features/schedules/data/datasources/schedule_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/schedules/data/repositories/schedule_repository_impl.dart';
import 'package:dispenxcore_frontend/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:dispenxcore_frontend/features/schedules/domain/usecases/schedule_usecases.dart';
import 'package:dispenxcore_frontend/features/dispenser/data/datasources/dispenser_remote_data_source.dart';
import 'package:dispenxcore_frontend/features/dispenser/data/repositories/dispenser_repository_impl.dart';
import 'package:dispenxcore_frontend/features/dispenser/domain/repositories/dispenser_repository.dart';
import 'package:dispenxcore_frontend/features/dispenser/domain/usecases/activate_dispenser.dart';
import 'package:dispenxcore_frontend/features/users/domain/usecases/update_user.dart';
import 'package:dispenxcore_frontend/core/services/edge_service.dart';
import 'package:dispenxcore_frontend/core/services/scheduler_service.dart';

// Infraestructura base
final TokenStorage tokenStorage = TokenStorageImpl();

final ApiClient apiClient = ApiClient(
  baseUrl: BASE_URL,
  tokenStorage: tokenStorage,
);

final ApiClient edgeApiClient = ApiClient(
  baseUrl: EDGE_BASE_URL,
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
final AlertsRemoteDataSource _alertsRemoteDataSource =
    AlertsRemoteDataSourceImpl(apiClient: apiClient, tokenStorage: tokenStorage);

final AlertsRepository alertsRepository =
    AlertsRepositoryImpl(remoteDataSource: _alertsRemoteDataSource);

// Users
final UserRemoteDataSource _userRemoteDataSource =
    UserRemoteDataSource(apiClient: apiClient);

final UserRepository userRepository =
    UserRepositoryImpl(remoteDataSource: _userRemoteDataSource);

// Dispensators
final DispensatorRemoteDataSource _dispensatorRemoteDataSource =
    DispensatorRemoteDataSource(apiClient: apiClient);

final DispensatorRepository dispensatorRepository =
    DispensatorRepositoryImpl(remoteDataSource: _dispensatorRemoteDataSource);

// Device
final DeviceRemoteDataSource _deviceRemoteDataSource =
    DeviceRemoteDataSource(apiClient: apiClient);

final DeviceRepository deviceRepository =
    DeviceRepositoryImpl(remoteDataSource: _deviceRemoteDataSource);

// History
final HistoryRemoteDataSource _historyRemoteDataSource =
    HistoryRemoteDataSource(apiClient: apiClient);

final HistoryRepository historyRepository =
    HistoryRepositoryImpl(dataSource: _historyRemoteDataSource);

// Inventario
final InventarioRemoteDataSource _inventarioRemoteDataSource =
    InventarioRemoteDataSource(apiClient: apiClient);

final InventarioRepository inventarioRepository =
    InventarioRepositoryImpl(dataSource: _inventarioRemoteDataSource);

// AlertasStock
final AlertasStockRemoteDataSource _alertasStockRemoteDataSource =
    AlertasStockRemoteDataSource(apiClient: apiClient);

final AlertasStockRepository alertasStockRepository =
    AlertasStockRepositoryImpl(dataSource: _alertasStockRemoteDataSource);

// Schedules
final ScheduleRemoteDataSource _scheduleRemoteDataSource =
    ScheduleRemoteDataSource(apiClient: apiClient);

final ScheduleRepository scheduleRepository =
    ScheduleRepositoryImpl(dataSource: _scheduleRemoteDataSource);

// Dispenser
final DispenserRemoteDataSource _dispenserRemoteDataSource =
    DispenserRemoteDataSource(apiClient: edgeApiClient);

final DispenserRepository dispenserRepository =
    DispenserRepositoryImpl(dataSource: _dispenserRemoteDataSource);

// Use cases
final LoginUser loginUserUseCase = LoginUser(authRepository);
final RegisterUser registerUserUseCase = RegisterUser(authRepository);
final GetNotifications getNotificationsUseCase = GetNotifications(alertsRepository);
final MarkNotificationAsRead markNotificationAsReadUseCase = MarkNotificationAsRead(alertsRepository);
final MarkAllNotificationsAsRead markAllNotificationsAsReadUseCase = MarkAllNotificationsAsRead(alertsRepository);
final GetCurrentUser getCurrentUserUseCase =
    GetCurrentUser(userRepository, tokenStorage);
final UpdateUser updateUserUseCase = UpdateUser(userRepository);
final ChangePassword changePasswordUseCase = ChangePassword(userRepository);
final GetDispensators getDispensatorsUseCase =
    GetDispensators(dispensatorRepository);
final GetDispensatorDetail getDispensatorDetailUseCase =
    GetDispensatorDetail(dispensatorRepository);
final GetDevice getDeviceUseCase = GetDevice(deviceRepository);
final UpdateDevice updateDeviceUseCase = UpdateDevice(deviceRepository);
final PingDevice pingDeviceUseCase = PingDevice(deviceRepository);
final GetDispenserEvents getDispenserEventsUseCase = GetDispenserEvents(historyRepository);
final GetInventarioEstado getInventarioEstadoUseCase = GetInventarioEstado(inventarioRepository);
final RegistrarMedicion registrarMedicionUseCase = RegistrarMedicion(inventarioRepository);
final GetAlertasStock getAlertasStockUseCase = GetAlertasStock(alertasStockRepository);
final EvaluarAlertaStock evaluarAlertaStockUseCase = EvaluarAlertaStock(alertasStockRepository);
final GetSchedules getSchedulesUseCase = GetSchedules(scheduleRepository);
final CreateSchedule createScheduleUseCase = CreateSchedule(scheduleRepository);
final UpdateSchedule updateScheduleUseCase = UpdateSchedule(scheduleRepository);
final DeleteSchedule deleteScheduleUseCase = DeleteSchedule(scheduleRepository);
final ToggleSchedule toggleScheduleUseCase = ToggleSchedule(scheduleRepository);
final ActivateDispenser activateDispenserUseCase = ActivateDispenser(dispenserRepository);

final EdgeService edgeService = EdgeService();
final SchedulerService schedulerService = SchedulerService(
  getSchedules: getSchedulesUseCase,
  getDevice: getDeviceUseCase,
  edgeService: edgeService,
);

T injector<T>() {
  if (T == TokenStorage) return tokenStorage as T;
  if (T == ApiClient) return apiClient as T;
  if (T == AuthRepository) return authRepository as T;
  if (T == LoginUser) return loginUserUseCase as T;
  if (T == RegisterUser) return registerUserUseCase as T;
  if (T == AlertsRepository) return alertsRepository as T;
  if (T == GetNotifications) return getNotificationsUseCase as T;
  if (T == MarkNotificationAsRead) return markNotificationAsReadUseCase as T;
  if (T == MarkAllNotificationsAsRead) return markAllNotificationsAsReadUseCase as T;
  if (T == UserRepository) return userRepository as T;
  if (T == GetCurrentUser) return getCurrentUserUseCase as T;
  if (T == UpdateUser) return updateUserUseCase as T;
  if (T == ChangePassword) return changePasswordUseCase as T;
  if (T == DispensatorRepository) return dispensatorRepository as T;
  if (T == GetDispensators) return getDispensatorsUseCase as T;
  if (T == GetDispensatorDetail) return getDispensatorDetailUseCase as T;
  if (T == DeviceRepository) return deviceRepository as T;
  if (T == GetDevice) return getDeviceUseCase as T;
  if (T == UpdateDevice) return updateDeviceUseCase as T;
  if (T == PingDevice) return pingDeviceUseCase as T;
  if (T == HistoryRepository) return historyRepository as T;
  if (T == GetDispenserEvents) return getDispenserEventsUseCase as T;
  if (T == InventarioRepository) return inventarioRepository as T;
  if (T == GetInventarioEstado) return getInventarioEstadoUseCase as T;
  if (T == RegistrarMedicion) return registrarMedicionUseCase as T;
  if (T == AlertasStockRepository) return alertasStockRepository as T;
  if (T == GetAlertasStock) return getAlertasStockUseCase as T;
  if (T == EvaluarAlertaStock) return evaluarAlertaStockUseCase as T;
  if (T == ScheduleRepository) return scheduleRepository as T;
  if (T == GetSchedules) return getSchedulesUseCase as T;
  if (T == CreateSchedule) return createScheduleUseCase as T;
  if (T == UpdateSchedule) return updateScheduleUseCase as T;
  if (T == DeleteSchedule) return deleteScheduleUseCase as T;
  if (T == ToggleSchedule) return toggleScheduleUseCase as T;
  if (T == DispenserRepository) return dispenserRepository as T;
  if (T == ActivateDispenser) return activateDispenserUseCase as T;
  if (T == EdgeService) return edgeService as T;
  if (T == SchedulerService) return schedulerService as T;

  throw Exception('Dependencia no registrada: $T');
}
