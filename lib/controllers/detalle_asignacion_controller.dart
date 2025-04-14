import 'package:donaciones_movil/models/detalle_asignacion.dart';
import 'package:donaciones_movil/services/detalle_asignacion_service.dart';
import 'package:flutter/material.dart';

class DetalleAsignacionController extends ChangeNotifier {
  final DetalleAsignacionService _service = DetalleAsignacionService();
  
  List<DetalleAsignacion>? _detalles;
  DetalleAsignacion? _selectedDetalle;
  bool _isLoading = false;
  String? _error;

  List<DetalleAsignacion>? get detalles => _detalles;
  DetalleAsignacion? get selectedDetalle => _selectedDetalle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDetallesAsignacion() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _detalles = await _service.getDetallesAsignacion();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetalleAsignacionById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDetalle = await _service.getDetalleAsignacionById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetallesByAsignacion(int asignacionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _detalles = await _service.getDetallesByAsignacion(asignacionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDetalleAsignacion(DetalleAsignacion detalle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDetalle = await _service.createDetalleAsignacion(detalle);
      if (_detalles != null) _detalles!.add(newDetalle);
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

  Future<bool> updateDetalleAsignacion(DetalleAsignacion detalle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDetalle = await _service.updateDetalleAsignacion(detalle);
      if (_detalles != null) {
        final index = _detalles!.indexWhere((d) => d.detalleId == detalle.detalleId);
        if (index != -1) _detalles![index] = updatedDetalle;
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

  Future<bool> deleteDetalleAsignacion(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDetalleAsignacion(id);
      if (_detalles != null) _detalles!.removeWhere((d) => d.detalleId == id);
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
}