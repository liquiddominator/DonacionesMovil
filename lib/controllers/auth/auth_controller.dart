import 'package:donaciones_movil/models/rol.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/models/usuario_rol.dart';
import 'package:donaciones_movil/services/rol_service.dart';
import 'package:donaciones_movil/services/usuario_rol_service.dart';
import 'package:donaciones_movil/services/usuario_service.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();
  final UsuarioRolService _usuarioRolService = UsuarioRolService();
  final RolService _rolService = RolService();
  
  Usuario? _currentUser;
  List<Rol>? _userRoles;
  bool _isLoading = false;
  String? _error;

  Usuario? get currentUser => _currentUser;
  List<Rol>? get userRoles => _userRoles;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Autenticar usuario
      final usuario = await _usuarioService.login(email, password);
      
      if (usuario != null) {
        _currentUser = usuario;
        
        // Cargar roles del usuario
        await _loadUserRoles(usuario.usuarioId);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Credenciales inválidas';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cargar roles del usuario autenticado
  Future<void> _loadUserRoles(int userId) async {
    try {
      // Obtener relaciones usuario-rol
      final userRolesRelations = await _usuarioRolService.getRolesByUsuarioId(userId);
      
      // Cargar los detalles de cada rol
      final roles = <Rol>[];
      for (var relation in userRolesRelations) {
        final rol = await _rolService.getRolById(relation.rolId);
        roles.add(rol);
      }
      
      _userRoles = roles;
    } catch (e) {
      _error = 'Error al cargar roles: ${e.toString()}';
    }
  }

  // Registro
  Future<bool> register(Usuario usuario, int rolId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Crear el usuario
      _currentUser = await _usuarioService.createUsuario(usuario);
      
      // Asignar rol al usuario
      if (_currentUser != null) {
        final usuarioRol = UsuarioRol(
          usuarioRolId: 0, // El ID será asignado por la API
          usuarioId: _currentUser!.usuarioId,
          rolId: rolId,
          fechaAsignacion: DateTime.now(),
        );
        
        await _usuarioRolService.createUsuarioRol(usuarioRol);
        
        // Cargar roles del usuario
        await _loadUserRoles(_currentUser!.usuarioId);
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

  // Comprobar si el usuario tiene un rol específico
  bool hasRole(String rolName) {
    return _userRoles?.any((rol) => rol.nombre == rolName) ?? false;
  }

  // Logout
  void logout() {
    _currentUser = null;
    _userRoles = null;
    notifyListeners();
  }
}