import 'package:donaciones_movil/models/comentario.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class ComentarioService {
  final ApiService _apiService = ApiService();

  Future<List<Comentario>> getComentarios() async {
    final data = await _apiService.get(ApiConstants.comentarioEndpoint);
    return (data as List).map((e) => Comentario.fromJson(e)).toList();
  }

  Future<Comentario> getComentarioById(String id) async {
    final data = await _apiService.get('${ApiConstants.comentarioEndpoint}/$id');
    return Comentario.fromJson(data);
  }

  Future<List<Comentario>> getComentariosByUsuario(int usuarioId) async {
    final data = await _apiService.get('${ApiConstants.comentarioEndpoint}/usuario/$usuarioId');
    return (data as List).map((e) => Comentario.fromJson(e)).toList();
  }

  Future<List<Comentario>> getComentariosByCalificacion(int calificacion) async {
    final data = await _apiService.get('${ApiConstants.comentarioEndpoint}/calificacion/$calificacion');
    return (data as List).map((e) => Comentario.fromJson(e)).toList();
  }

  Future<double> getPromedioCalificacion() async {
    final data = await _apiService.get('${ApiConstants.comentarioEndpoint}/promedio');
    return (data as num).toDouble();
  }

  Future<Comentario> createComentario(Comentario comentario) async {
    final data = await _apiService.post(
      ApiConstants.comentarioEndpoint,
      comentario.toJson(),
    );
    return Comentario.fromJson(data);
  }

  Future<Comentario> updateComentario(String id, Comentario comentario) async {
    final data = await _apiService.put(
      '${ApiConstants.comentarioEndpoint}/$id',
      comentario.toJson(),
    );
    return Comentario.fromJson(data);
  }

  Future<void> deleteComentario(String id) async {
    await _apiService.delete('${ApiConstants.comentarioEndpoint}/$id');
  }

  Future<List<Comentario>> getComentariosByDonacion(int donacionId) async {
    final data = await _apiService.get('${ApiConstants.comentarioEndpoint}/donacion/$donacionId');
    return (data as List).map((e) => Comentario.fromJson(e)).toList();
  }
}