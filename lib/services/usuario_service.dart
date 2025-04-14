import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class UsuarioService {
  final ApiService _apiService = ApiService();

  // Obtener todos los usuarios
  Future<List<Usuario>> getUsuarios() async {
    final data = await _apiService.get(ApiConstants.userEndpoint);
    return (data as List).map((item) => Usuario.fromJson(item)).toList();
  }

  // Obtener usuario por ID
  Future<Usuario> getUsuarioById(int id) async {
    final data = await _apiService.get('${ApiConstants.userEndpoint}/$id');
    return Usuario.fromJson(data);
  }

  // Crear usuario
  Future<Usuario> createUsuario(Usuario usuario) async {
    final data = await _apiService.post(
      ApiConstants.userEndpoint,
      usuario.toJson(),
    );
    return Usuario.fromJson(data);
  }

  // Actualizar usuario
  Future<Usuario> updateUsuario(Usuario usuario) async {
    final data = await _apiService.put(
      '${ApiConstants.userEndpoint}/${usuario.usuarioId}',
      usuario.toJson(),
    );
    return Usuario.fromJson(data);
  }

  // Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    await _apiService.delete('${ApiConstants.userEndpoint}/$id');
  }

  // Login (autenticación simple)
  Future<Usuario?> login(String email, String password) async {
    try {
      // Obtener todos los usuarios y filtrar por email/contraseña
      final usuarios = await getUsuarios();
      return usuarios.firstWhere(
        (u) => u.email == email && u.contrasena == password,
      );
    } catch (e) {
      return null;
    }
  }
}