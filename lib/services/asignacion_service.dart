import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class AsignacionService {
  final ApiService _apiService = ApiService();

  Future<List<Asignacion>> getAsignaciones() async {
    final data = await _apiService.get(ApiConstants.asignacionEndpoint);
    return (data as List).map((item) => Asignacion.fromJson(item)).toList();
  }

  Future<Asignacion> getAsignacionById(int id) async {
    final data = await _apiService.get('${ApiConstants.asignacionEndpoint}/$id');
    return Asignacion.fromJson(data);
  }

  Future<List<Asignacion>> getAsignacionesByCampania(int campaniaId) async {
    final data = await _apiService.get('${ApiConstants.asignacionEndpoint}/campania/$campaniaId');
    return (data as List).map((item) => Asignacion.fromJson(item)).toList();
  }

  Future<List<Asignacion>> getAsignacionesByUsuario(int usuarioId) async {
    final data = await _apiService.get('${ApiConstants.asignacionEndpoint}/usuario/$usuarioId');
    return (data as List).map((item) => Asignacion.fromJson(item)).toList();
  }

  Future<Asignacion> createAsignacion(Asignacion asignacion) async {
    final data = await _apiService.post(
      ApiConstants.asignacionEndpoint,
      asignacion.toJson(),
    );
    return Asignacion.fromJson(data);
  }

  Future<Asignacion> updateAsignacion(Asignacion asignacion) async {
    final data = await _apiService.put(
      '${ApiConstants.asignacionEndpoint}/${asignacion.asignacionId}',
      asignacion.toJson(),
    );
    return Asignacion.fromJson(data);
  }

  Future<void> deleteAsignacion(int id) async {
    await _apiService.delete('${ApiConstants.asignacionEndpoint}/$id');
  }
}