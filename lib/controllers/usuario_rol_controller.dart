import 'package:donaciones_movil/models/usuario_rol.dart';
import 'package:donaciones_movil/services/usuario_rol_service.dart';
import 'package:flutter/material.dart';

class UsuarioRolController extends ChangeNotifier {
  final UsuarioRolService _service = UsuarioRolService();
  
  List<UsuarioRol>? _usuariosRoles;
  UsuarioRol? _selectedUsuarioRol;
  bool _isLoading = false;
  String? _error;

  List<UsuarioRol>? get usuariosRoles => _usuariosRoles;
  UsuarioRol? get selectedUsuarioRol => _selectedUsuarioRol;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsuariosRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuariosRoles = await _service.getUsuariosRoles();
    } catch (e) {
      _error = 'Error al cargar relaciones usuario-rol: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRolesByUsuarioId(int usuarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuariosRoles = await _service.getRolesByUsuarioId(usuarioId);
    } catch (e) {
      _error = 'Error al cargar roles del usuario: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsuariosByRolId(int rolId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usuariosRoles = await _service.getUsuariosByRolId(rolId);
    } catch (e) {
      _error = 'Error al cargar usuarios por rol: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> asignarRolAUsuario(UsuarioRol usuarioRol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUsuarioRol = await _service.createUsuarioRol(usuarioRol);
      _usuariosRoles?.add(newUsuarioRol);
      return true;
    } catch (e) {
      _error = 'Error al asignar rol: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarAsignacionRol(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteUsuarioRol(id);
      _usuariosRoles?.removeWhere((ur) => ur.usuarioRolId == id);
      if (_selectedUsuarioRol?.usuarioRolId == id) {
        _selectedUsuarioRol = null;
      }
      return true;
    } catch (e) {
      _error = 'Error al eliminar asignación: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}