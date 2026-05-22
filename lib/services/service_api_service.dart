import '../models/service_model.dart';
import 'api_client.dart';

class ServiceApiService {
  ServiceApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServiceModel>> fetchServices() async {
    final response = await _apiClient.get('/services') as Map<String, dynamic>;
    final data = response['data'] as List<dynamic>;
    return data
        .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceModel> fetchService(int id) async {
    final response =
        await _apiClient.get('/services/$id') as Map<String, dynamic>;
    return ServiceModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
