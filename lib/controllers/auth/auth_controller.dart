import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/services/usuario_service.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final UsuarioService _usuarioService = UsuarioService();
  
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _usuarioService.login(email, password);
      
      if (usuario != null) {
        _currentUser = usuario;
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

  // Registro
  Future<bool> register(Usuario usuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _usuarioService.createUsuario(usuario);
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

  // Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}