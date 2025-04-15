import 'package:donaciones_movil/models/rol.dart';
import 'package:donaciones_movil/services/rol_service.dart';
import 'package:flutter/material.dart';

class RolController extends ChangeNotifier {
  final RolService _service = RolService();
  
  List<Rol>? _roles;
  Rol? _selectedRol;
  bool _isLoading = false;
  String? _error;

  List<Rol>? get roles => _roles;
  Rol? get selectedRol => _selectedRol;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _roles = await _service.getRoles();
    } catch (e) {
      _error = 'Error al cargar roles: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRol(Rol rol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRol = await _service.createRol(rol);
      _roles?.add(newRol);
      return true;
    } catch (e) {
      _error = 'Error al crear rol: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRol(Rol rol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedRol = await _service.updateRol(rol);
      final index = _roles?.indexWhere((r) => r.rolId == rol.rolId) ?? -1;
      if (index != -1) {
        _roles?[index] = updatedRol;
      }
      if (_selectedRol?.rolId == rol.rolId) {
        _selectedRol = updatedRol;
      }
      return true;
    } catch (e) {
      _error = 'Error al actualizar rol: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRol(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteRol(id);
      _roles?.removeWhere((r) => r.rolId == id);
      if (_selectedRol?.rolId == id) {
        _selectedRol = null;
      }
      return true;
    } catch (e) {
      _error = 'Error al eliminar rol: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}