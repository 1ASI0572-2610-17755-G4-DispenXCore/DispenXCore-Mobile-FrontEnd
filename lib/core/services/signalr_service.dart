import 'package:signalr_core/signalr_core.dart';
import '../constants.dart';
import '../storage/token_storage.dart';
 
/// Callback que se dispara cuando el servidor notifica un cambio de estado en un job.
/// El feature que consuma este servicio decide qué hacer con los datos.
typedef OnJobStatusChanged = void Function({
  required String jobId,
  required String status,
  String? professionalId,
  double? proposedCost,
});
 
class SignalRService {
  final TokenStorage tokenStorage;
  final OnJobStatusChanged onJobStatusChanged;
 
  HubConnection? _hubConnection;
 
  final String _hubUrl =
      '${BASE_URL.replaceAll('/api/v1', '')}/hubs/servicerequests';
 
  SignalRService({
    required this.tokenStorage,
    required this.onJobStatusChanged,
  });
 
  Future<void> connect() async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      return;
    }
 
    final token = await tokenStorage.getToken();
    if (token == null) {
      print('SignalR: No hay token, no se puede conectar.');
      return;
    }
 
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();
 
    // Evento: solicitud aceptada
    _hubConnection!.on('RequestAccepted', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
 
      try {
        final data = arguments[0] as Map<String, dynamic>;
 
        final jobId =
            (data['jobId'] ?? data['JobId'])?.toString() ?? '';
        final professionalId =
            (data['professionalId'] ?? data['ProfessionalId'])?.toString() ?? '';
        final costRaw = data['proposedCost'] ?? data['ProposedCost'];
        final proposedCost =
            costRaw != null ? (costRaw as num).toDouble() : null;
 
        onJobStatusChanged(
          jobId: jobId,
          status: 'Accepted',
          professionalId: professionalId,
          proposedCost: proposedCost,
        );
      } catch (e) {
        print('SignalR: Error parseando RequestAccepted: $e');
      }
    });
 
    // Evento: solicitud rechazada
    _hubConnection!.on('RequestDeclined', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
 
      try {
        final data = arguments[0] as Map<String, dynamic>;
        final jobId =
            (data['jobId'] ?? data['JobId'])?.toString() ?? '';
 
        onJobStatusChanged(
          jobId: jobId,
          status: 'Declined',
        );
      } catch (e) {
        print('SignalR: Error parseando RequestDeclined: $e');
      }
    });
 
    try {
      await _hubConnection!.start();
      print('SignalR: Conectado. ID: ${_hubConnection?.connectionId}');
    } catch (e) {
      print('SignalR: Error al conectar: $e');
    }
  }
 
  void disconnect() {
    _hubConnection?.stop();
    print('SignalR: Desconectado.');
  }
}