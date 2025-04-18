import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/services/asignacion_service.dart';
import 'package:flutter/material.dart';

class AsignacionController extends ChangeNotifier {
  final AsignacionService _asignacionService = AsignacionService();
  
  List<Asignacion> _asignaciones = [];
  Asignacion? _selectedAsignacion;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Asignacion> get asignaciones => _asignaciones;
  Asignacion? get selectedAsignacion => _selectedAsignacion;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Obtener todas las asignaciones
  Future<void> fetchAsignaciones() async {
    _setLoading(true);
    try {
      _asignaciones = await _asignacionService.getAsignaciones();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error al cargar asignaciones: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Obtener asignación por ID
  Future<void> fetchAsignacionById(int id) async {
    _setLoading(true);
    try {
      _selectedAsignacion = await _asignacionService.getAsignacionById(id);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error al cargar la asignación: ${e.toString()}';
      _selectedAsignacion = null;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener asignaciones por campaña
  Future<List<Asignacion>> fetchAsignacionesByCampania(int campaniaId) async {
    _setLoading(true);
    try {
      final asignacionesCampania = await _asignacionService.getAsignacionesByCampania(campaniaId);
      _errorMessage = '';
      return asignacionesCampania;
    } catch (e) {
      _errorMessage = 'Error al cargar asignaciones de campaña: ${e.toString()}';
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Obtener asignaciones por usuario
Future<List<Asignacion>> fetchAsignacionesByUsuario(int usuarioId) async {
  _setLoading(true);
  try {
    final asignacionesUsuario = await _asignacionService.getAsignacionesByUsuario(usuarioId);
    _asignaciones = asignacionesUsuario; // <-- esto actualiza la lista interna
    _errorMessage = '';
    notifyListeners(); // <-- esto permite que la UI se reconstruya
    return asignacionesUsuario;
  } catch (e) {
    _errorMessage = 'Error al cargar asignaciones del usuario: ${e.toString()}';
    return [];
  } finally {
    _setLoading(false);
  }
}


  // Crear asignación
  Future<bool> createAsignacion(Asignacion asignacion) async {
    _setLoading(true);
    try {
      final createdAsignacion = await _asignacionService.createAsignacion(asignacion);
      _asignaciones.add(createdAsignacion);
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear asignación: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar asignación
  Future<bool> updateAsignacion(Asignacion asignacion) async {
    _setLoading(true);
    try {
      final updatedAsignacion = await _asignacionService.updateAsignacion(asignacion);
      
      // Actualizar en la lista
      final index = _asignaciones.indexWhere(
        (a) => a.asignacionId == updatedAsignacion.asignacionId
      );
      
      if (index != -1) {
        _asignaciones[index] = updatedAsignacion;
      }
      
      // Actualizar la seleccionada si es la misma
      if (_selectedAsignacion?.asignacionId == updatedAsignacion.asignacionId) {
        _selectedAsignacion = updatedAsignacion;
      }
      
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar asignación: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar asignación
  Future<bool> deleteAsignacion(int id) async {
    _setLoading(true);
    try {
      await _asignacionService.deleteAsignacion(id);
      
      // Eliminar de la lista
      _asignaciones.removeWhere((a) => a.asignacionId == id);
      
      // Limpiar la seleccionada si es la misma
      if (_selectedAsignacion?.asignacionId == id) {
        _selectedAsignacion = null;
      }
      
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar asignación: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar asignación
  void selectAsignacion(Asignacion asignacion) {
    _selectedAsignacion = asignacion;
    notifyListeners();
  }

  // Limpiar selección
  void clearSelection() {
    _selectedAsignacion = null;
    notifyListeners();
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Método auxiliar para actualizar estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}