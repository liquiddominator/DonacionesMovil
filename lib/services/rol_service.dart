import 'package:donaciones_movil/models/rol.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class RolService {
  final ApiService _apiService = ApiService();

  Future<List<Rol>> getRoles() async {
    final data = await _apiService.get(ApiConstants.rolesEndpoint);
    return (data as List).map((item) => Rol.fromJson(item)).toList();
  }

  Future<Rol> getRolById(int id) async {
    final data = await _apiService.get('${ApiConstants.rolesEndpoint}/$id');
    return Rol.fromJson(data);
  }

  Future<Rol> createRol(Rol rol) async {
    final data = await _apiService.post(
      ApiConstants.rolesEndpoint,
      rol.toJson(),
    );
    return Rol.fromJson(data);
  }

  Future<Rol> updateRol(Rol rol) async {
    final data = await _apiService.put(
      '${ApiConstants.rolesEndpoint}/${rol.rolId}',
      rol.toJson(),
    );
    return Rol.fromJson(data);
  }

  Future<void> deleteRol(int id) async {
    await _apiService.delete('${ApiConstants.rolesEndpoint}/$id');
  }
}