import 'package:donaciones_movil/models/detalle_asignacion.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class DetalleAsignacionService {
  final ApiService _apiService = ApiService();

  Future<List<DetalleAsignacion>> getDetallesAsignacion() async {
    final data = await _apiService.get(ApiConstants.detalleAsignacionEndpoint);
    return (data as List).map((item) => DetalleAsignacion.fromJson(item)).toList();
  }

  Future<DetalleAsignacion> getDetalleAsignacionById(int id) async {
    final data = await _apiService.get('${ApiConstants.detalleAsignacionEndpoint}/$id');
    return DetalleAsignacion.fromJson(data);
  }

  Future<List<DetalleAsignacion>> getDetallesByAsignacion(int asignacionId) async {
    final data = await _apiService.get('${ApiConstants.detalleAsignacionEndpoint}/asignacion/$asignacionId');
    return (data as List).map((item) => DetalleAsignacion.fromJson(item)).toList();
  }

  Future<DetalleAsignacion> createDetalleAsignacion(DetalleAsignacion detalle) async {
    final data = await _apiService.post(
      ApiConstants.detalleAsignacionEndpoint,
      detalle.toJson(),
    );
    return DetalleAsignacion.fromJson(data);
  }

  Future<DetalleAsignacion> updateDetalleAsignacion(DetalleAsignacion detalle) async {
    final data = await _apiService.put(
      '${ApiConstants.detalleAsignacionEndpoint}/${detalle.detalleId}',
      detalle.toJson(),
    );
    return DetalleAsignacion.fromJson(data);
  }

  Future<void> deleteDetalleAsignacion(int id) async {
    await _apiService.delete('${ApiConstants.detalleAsignacionEndpoint}/$id');
  }
}