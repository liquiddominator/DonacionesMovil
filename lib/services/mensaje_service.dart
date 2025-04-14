import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class MensajeService {
  final ApiService _apiService = ApiService();

  Future<List<Mensaje>> getMensajes() async {
    final data = await _apiService.get(ApiConstants.mensajeEndpoint);
    return (data as List).map((item) => Mensaje.fromJson(item)).toList();
  }

  Future<Mensaje> getMensajeById(int id) async {
    final data = await _apiService.get('${ApiConstants.mensajeEndpoint}/$id');
    return Mensaje.fromJson(data);
  }

  Future<List<Mensaje>> getMensajesByUsuario(int usuarioId) async {
    final data = await _apiService.get('${ApiConstants.mensajeEndpoint}/usuario/$usuarioId');
    return (data as List).map((item) => Mensaje.fromJson(item)).toList();
  }

  Future<Mensaje> createMensaje(Mensaje mensaje) async {
    final data = await _apiService.post(
      ApiConstants.mensajeEndpoint,
      mensaje.toJson(),
    );
    return Mensaje.fromJson(data);
  }

  Future<Mensaje> updateMensaje(Mensaje mensaje) async {
    final data = await _apiService.put(
      '${ApiConstants.mensajeEndpoint}/${mensaje.mensajeId}',
      mensaje.toJson(),
    );
    return Mensaje.fromJson(data);
  }

  Future<void> deleteMensaje(int id) async {
    await _apiService.delete('${ApiConstants.mensajeEndpoint}/$id');
  }
}