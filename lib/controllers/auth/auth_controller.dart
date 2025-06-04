import 'package:bcrypt/bcrypt.dart';
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
    // Encriptar la contraseña antes de enviarla
    final hashedPassword = BCrypt.hashpw(usuario.contrasena, BCrypt.gensalt());

    // Crear copia del usuario con contraseña hasheada
    final usuarioHashed = Usuario(
      usuarioId: usuario.usuarioId,
      email: usuario.email,
      contrasena: hashedPassword,
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      telefono: usuario.telefono,
      imagenUrl: usuario.imagenUrl,
      activo: usuario.activo,
      fechaRegistro: usuario.fechaRegistro,
    );

    // Crear el usuario
    _currentUser = await _usuarioService.createUsuario(usuarioHashed);

    // Asignar rol
    if (_currentUser != null) {
      final usuarioRol = UsuarioRol(
        usuarioRolId: 0,
        usuarioId: _currentUser!.usuarioId,
        rolId: rolId,
        fechaAsignacion: DateTime.now(),
      );
      await _usuarioRolService.createUsuarioRol(usuarioRol);
      await _loadUserRoles(_currentUser!.usuarioId);
    }

    if (_currentUser != null) {
  setCurrentUser(_currentUser!); // <- Esto asegura la persistencia en el árbol de widgets
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

  void setCurrentUser(Usuario usuario) {
    _currentUser = usuario;
    notifyListeners();
  }


  // Logout
  void logout() {
    _currentUser = null;
    _userRoles = null;
    notifyListeners();
  }
}