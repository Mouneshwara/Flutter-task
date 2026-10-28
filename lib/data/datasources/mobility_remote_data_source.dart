import '../../core/network/api_client.dart';
import '../models/city_model.dart';
import '../models/connection_model.dart';

class MobilityRemoteDataSource {
  const MobilityRemoteDataSource(this.apiClient);
  final ApiClient apiClient;

  Future<List<ConnectionModel>> fetchConnections() async {
    final payload = await apiClient.getJson('/connections');
    final rows = _asList(payload, const ['connections', 'data', 'results']);
    return rows.map((item) {
      if (item is! Map) throw const FormatException('Invalid connection item.');
      return ConnectionModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<List<CityModel>> fetchCities() async {
    final payload = await apiClient.getJson('/cities');
    final rows = _asList(payload, const ['cities', 'data', 'results']);
    return rows.map((item) {
      if (item is! Map) throw const FormatException('Invalid city item.');
      return CityModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  List<dynamic> _asList(dynamic payload, List<String> keys) {
    if (payload is List) return payload;
    if (payload is Map) {
      for (final key in keys) {
        if (payload[key] is List) return payload[key] as List<dynamic>;
      }
    }
    throw const FormatException('Unexpected API response format: expected a list.');
  }
}
