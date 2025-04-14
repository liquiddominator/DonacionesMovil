import 'package:donaciones_movil/models/estado.dart';
import 'package:donaciones_movil/services/estado_service.dart';
import 'package:flutter/material.dart';

class EstadoController extends ChangeNotifier {
  final EstadoService _service = EstadoService();
  
  List<Estado>? _estados;
  Estado? _selectedEstado;
  bool _isLoading = false;
  String? _error;

  List<Estado>? get estados => _estados;
  Estado? get selectedEstado => _selectedEstado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEstados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _estados = await _service.getEstados();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEstadoById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEstado = await _service.getEstadoById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEstado(Estado estado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEstado = await _service.createEstado(estado);
      if (_estados != null) _estados!.add(newEstado);
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

  Future<bool> updateEstado(Estado estado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEstado = await _service.updateEstado(estado);
      if (_estados != null) {
        final index = _estados!.indexWhere((e) => e.estadoId == estado.estadoId);
        if (index != -1) _estados![index] = updatedEstado;
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

  Future<bool> deleteEstado(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteEstado(id);
      if (_estados != null) _estados!.removeWhere((e) => e.estadoId == id);
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