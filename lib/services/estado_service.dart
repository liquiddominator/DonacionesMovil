import 'package:donaciones_movil/models/estado.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class EstadoService {
  final ApiService _apiService = ApiService();

  Future<List<Estado>> getEstados() async {
    final data = await _apiService.get(ApiConstants.estadoEndpoint);
    return (data as List).map((item) => Estado.fromJson(item)).toList();
  }

  Future<Estado> getEstadoById(int id) async {
    final data = await _apiService.get('${ApiConstants.estadoEndpoint}/$id');
    return Estado.fromJson(data);
  }

  Future<Estado> createEstado(Estado estado) async {
    final data = await _apiService.post(
      ApiConstants.estadoEndpoint,
      estado.toJson(),
    );
    return Estado.fromJson(data);
  }

  Future<Estado> updateEstado(Estado estado) async {
    final data = await _apiService.put(
      '${ApiConstants.estadoEndpoint}/${estado.estadoId}',
      estado.toJson(),
    );
    return Estado.fromJson(data);
  }

  Future<void> deleteEstado(int id) async {
    await _apiService.delete('${ApiConstants.estadoEndpoint}/$id');
  }
}