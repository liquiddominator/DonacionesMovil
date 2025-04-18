import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/services/usuario_service.dart';
import 'package:flutter/material.dart';

class UserController extends ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();
  
  List<Usuario>? _usuarios;
  Usuario? _selectedUsuario;
  bool _isLoading = false;
  String? _error;

  List<Usuario>? get usuarios => _usuarios;
  Usuario? get selectedUsuario => _selectedUsuario;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todos los usuarios
  Future<void> loadUsuarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarios = await _usuarioService.getUsuarios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar usuario por ID
  Future<void> loadUsuario(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedUsuario = await _usuarioService.getUsuarioById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Usuario> getUsuarioById(int id) async {
    return await _usuarioService.getUsuarioById(id);
  }

  // Crear usuario
  Future<bool> createUsuario(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUsuario = await _usuarioService.createUsuario(usuario);
      
      // Agregar a la lista si ya está cargada
      if (_usuarios != null) {
        _usuarios!.add(newUsuario);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Actualizar usuario existente
Future<bool> updateUsuario(Usuario usuario) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final updated = await _usuarioService.updateUsuario(usuario);

    // Reemplazar en la lista si existe
    final index = _usuarios?.indexWhere((u) => u.usuarioId == usuario.usuarioId) ?? -1;
    if (index != -1 && _usuarios != null) {
      _usuarios![index] = updated;
    }

    // Actualizar usuario seleccionado
    if (_selectedUsuario?.usuarioId == usuario.usuarioId) {
      _selectedUsuario = updated;
    }

    notifyListeners();
    return true;
  } catch (e) {
    _error = 'Error al actualizar usuario: ${e.toString()}';
    notifyListeners();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

}