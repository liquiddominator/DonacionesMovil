import 'package:donaciones_movil/models/donacion_asignacion.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class DonacionAsignacionService {
  final ApiService _apiService = ApiService();

  Future<List<DonacionAsignacion>> getDonacionAsignaciones() async {
    final data = await _apiService.get(ApiConstants.donacionAsignacionEndpoint);
    return (data as List).map((item) => DonacionAsignacion.fromJson(item)).toList();
  }

  Future<DonacionAsignacion> getDonacionAsignacionById(int id) async {
    final data = await _apiService.get('${ApiConstants.donacionAsignacionEndpoint}/$id');
    return DonacionAsignacion.fromJson(data);
  }

  Future<List<DonacionAsignacion>> getAsignacionesByDonacion(int donacionId) async {
    final data = await _apiService.get('${ApiConstants.donacionAsignacionEndpoint}/donacion/$donacionId');
    return (data as List).map((item) => DonacionAsignacion.fromJson(item)).toList();
  }

  Future<List<DonacionAsignacion>> getAsignacionesByAsignacion(int asignacionId) async {
    final data = await _apiService.get('${ApiConstants.donacionAsignacionEndpoint}/asignacion/$asignacionId');
    return (data as List).map((item) => DonacionAsignacion.fromJson(item)).toList();
  }

  Future<DonacionAsignacion> createDonacionAsignacion(DonacionAsignacion donacionAsignacion) async {
    final data = await _apiService.post(
      ApiConstants.donacionAsignacionEndpoint,
      donacionAsignacion.toJson(),
    );
    return DonacionAsignacion.fromJson(data);
  }

  Future<DonacionAsignacion> updateDonacionAsignacion(DonacionAsignacion donacionAsignacion) async {
    final data = await _apiService.put(
      '${ApiConstants.donacionAsignacionEndpoint}/${donacionAsignacion.donacionAsignacionId}',
      donacionAsignacion.toJson(),
    );
    return DonacionAsignacion.fromJson(data);
  }

  Future<void> deleteDonacionAsignacion(int id) async {
    await _apiService.delete('${ApiConstants.donacionAsignacionEndpoint}/$id');
  }
}