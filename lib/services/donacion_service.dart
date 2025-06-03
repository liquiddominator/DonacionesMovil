import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class DonacionService {
  final ApiService _apiService = ApiService();

  // Obtener todas las donaciones
  Future<List<Donacion>> getDonaciones() async {
    final data = await _apiService.get(ApiConstants.donacionEndpoint);
    return (data as List).map((item) => Donacion.fromJson(item)).toList();
  }

  // Obtener donación por ID
  Future<Donacion> getDonacionById(int id) async {
    final data = await _apiService.get('${ApiConstants.donacionEndpoint}/$id');
    return Donacion.fromJson(data);
  }

  // Crear donación
  Future<Donacion> createDonacion(Donacion donacion) async {
    final data = await _apiService.post(
      ApiConstants.donacionEndpoint,
      donacion.toJson(),
    );
    return Donacion.fromJson(data);
  }

  // Eliminar donación
  Future<void> deleteDonacion(int id) async {
    await _apiService.delete('${ApiConstants.donacionEndpoint}/$id');
  }

  // Obtener donaciones por campaña
  Future<List<Donacion>> getDonacionesByCampania(int campaniaId) async {
    final data = await _apiService.get('${ApiConstants.donacionEndpoint}/campania/$campaniaId');
    return (data as List).map((item) => Donacion.fromJson(item)).toList();
  }

  // Obtener donaciones por usuario
  Future<List<Donacion>> getDonacionesByUsuario(int usuarioId) async {
    final data = await _apiService.get('${ApiConstants.donacionEndpoint}/usuario/$usuarioId');
    return (data as List).map((item) => Donacion.fromJson(item)).toList();
  }

  Future<int> getCantidadDonantesPorCampania(int campaniaId) async {
    final data = await _apiService.get('${ApiConstants.campaniaDonantesCountEndpoint}/$campaniaId/donantes-count');
    return data as int;
  }
}