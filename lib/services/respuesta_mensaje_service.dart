import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class RespuestaMensajeService {
  final ApiService _apiService = ApiService();

  Future<List<RespuestaMensaje>> getRespuestas() async {
    final data = await _apiService.get(ApiConstants.respuestaMensajeEndpoint);
    return (data as List).map((item) => RespuestaMensaje.fromJson(item)).toList();
  }

  Future<RespuestaMensaje> getRespuestaById(int id) async {
    final data = await _apiService.get('${ApiConstants.respuestaMensajeEndpoint}/$id');
    return RespuestaMensaje.fromJson(data);
  }

  Future<List<RespuestaMensaje>> getRespuestasByMensaje(int mensajeId) async {
    final data = await _apiService.get('${ApiConstants.respuestaMensajeEndpoint}/mensaje/$mensajeId');
    return (data as List).map((item) => RespuestaMensaje.fromJson(item)).toList();
  }

  Future<RespuestaMensaje> createRespuesta(RespuestaMensaje respuesta) async {
    final data = await _apiService.post(
      ApiConstants.respuestaMensajeEndpoint,
      respuesta.toJson(),
    );
    return RespuestaMensaje.fromJson(data);
  }

  Future<void> deleteRespuesta(int id) async {
    await _apiService.delete('${ApiConstants.respuestaMensajeEndpoint}/$id');
  }
}