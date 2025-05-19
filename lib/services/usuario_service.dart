import 'package:bcrypt/bcrypt.dart';
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
  final response = await _apiService.put(
    '${ApiConstants.userEndpoint}/${usuario.usuarioId}',
    usuario.toJson(),
  );

  // Si no hay cuerpo, retornamos el mismo objeto (ya que fue exitoso)
  if (response == null) return usuario;

  return Usuario.fromJson(response);
}


  // Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    await _apiService.delete('${ApiConstants.userEndpoint}/$id');
  }

  // Login (autenticación simple)
  Future<Usuario?> login(String email, String password) async {
  try {
    final usuarios = await getUsuarios();
    final usuario = usuarios.firstWhere((u) => u.email == email, orElse: () => throw Exception("Usuario no encontrado"));
    
    final isValid = BCrypt.checkpw(password, usuario.contrasena);
    return isValid ? usuario : null;
  } catch (e) {
    return null;
  }
}

}