import 'package:donaciones_movil/models/usuario_rol.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class UsuarioRolService {
  final ApiService _apiService = ApiService();

  Future<List<UsuarioRol>> getUsuariosRoles() async {
    final data = await _apiService.get(ApiConstants.usuariosRolesEndpoint);
    return (data as List).map((item) => UsuarioRol.fromJson(item)).toList();
  }

  Future<UsuarioRol> getUsuarioRolById(int id) async {
    final data = await _apiService.get('${ApiConstants.usuariosRolesEndpoint}/$id');
    return UsuarioRol.fromJson(data);
  }

  Future<UsuarioRol> createUsuarioRol(UsuarioRol usuarioRol) async {
    final data = await _apiService.post(
      ApiConstants.usuariosRolesEndpoint,
      usuarioRol.toJson(),
    );
    return UsuarioRol.fromJson(data);
  }

  Future<UsuarioRol> updateUsuarioRol(UsuarioRol usuarioRol) async {
    final data = await _apiService.put(
      '${ApiConstants.usuariosRolesEndpoint}/${usuarioRol.usuarioRolId}',
      usuarioRol.toJson(),
    );
    return UsuarioRol.fromJson(data);
  }

  Future<void> deleteUsuarioRol(int id) async {
    await _apiService.delete('${ApiConstants.usuariosRolesEndpoint}/$id');
  }

  Future<List<UsuarioRol>> getRolesByUsuarioId(int usuarioId) async {
    final data = await _apiService.get('${ApiConstants.usuariosRolesEndpoint}/usuario/$usuarioId');
    return (data as List).map((item) => UsuarioRol.fromJson(item)).toList();
  }

  Future<List<UsuarioRol>> getUsuariosByRolId(int rolId) async {
    final data = await _apiService.get('${ApiConstants.usuariosRolesEndpoint}/rol/$rolId');
    return (data as List).map((item) => UsuarioRol.fromJson(item)).toList();
  }
}