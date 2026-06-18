import 'package:dispenxcore_frontend/core/api/api_client.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator.dart';
import 'package:dispenxcore_frontend/features/dispensators/domain/entities/dispensator_detail.dart';

class DispensatorRemoteDataSource {
  final ApiClient apiClient;
  DispensatorRemoteDataSource({required this.apiClient});

  Future<List<Dispensator>> getDispensators() async {
    final data = await apiClient.get('/api/v1/dispensators');
    final list = data as List<dynamic>;
    return list
        .map((e) => Dispensator.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DispensatorDetail> getDispensatorDetail(int id) async {
    final data = await apiClient.get('/api/v1/dispensators/$id');
    return DispensatorDetail.fromJson(data as Map<String, dynamic>);
  }
}
