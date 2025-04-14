import 'package:donaciones_movil/models/donacion_asignacion.dart';
import 'package:donaciones_movil/services/donacion_asignacion_service.dart';
import 'package:flutter/material.dart';

class DonacionAsignacionController extends ChangeNotifier {
  final DonacionAsignacionService _service = DonacionAsignacionService();
  
  List<DonacionAsignacion>? _donacionAsignaciones;
  DonacionAsignacion? _selectedDonacionAsignacion;
  bool _isLoading = false;
  String? _error;

  List<DonacionAsignacion>? get donacionAsignaciones => _donacionAsignaciones;
  DonacionAsignacion? get selectedDonacionAsignacion => _selectedDonacionAsignacion;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDonacionAsignaciones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donacionAsignaciones = await _service.getDonacionAsignaciones();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDonacionAsignacionById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDonacionAsignacion = await _service.getDonacionAsignacionById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAsignacionesByDonacion(int donacionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donacionAsignaciones = await _service.getAsignacionesByDonacion(donacionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAsignacionesByAsignacion(int asignacionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donacionAsignaciones = await _service.getAsignacionesByAsignacion(asignacionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDonacionAsignacion(DonacionAsignacion donacionAsignacion) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDonacionAsignacion = await _service.createDonacionAsignacion(donacionAsignacion);
      if (_donacionAsignaciones != null) _donacionAsignaciones!.add(newDonacionAsignacion);
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

  Future<bool> updateDonacionAsignacion(DonacionAsignacion donacionAsignacion) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDonacionAsignacion = await _service.updateDonacionAsignacion(donacionAsignacion);
      if (_donacionAsignaciones != null) {
        final index = _donacionAsignaciones!.indexWhere((da) => da.donacionAsignacionId == donacionAsignacion.donacionAsignacionId);
        if (index != -1) _donacionAsignaciones![index] = updatedDonacionAsignacion;
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

  Future<bool> deleteDonacionAsignacion(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDonacionAsignacion(id);
      if (_donacionAsignaciones != null) _donacionAsignaciones!.removeWhere((da) => da.donacionAsignacionId == id);
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