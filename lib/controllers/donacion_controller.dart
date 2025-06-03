import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/services/donacion_service.dart';
import 'package:flutter/material.dart';

class DonacionController extends ChangeNotifier {
  final DonacionService _donacionService = DonacionService();

  List<Donacion>? _donaciones;         // Donaciones del usuario actual
  List<Donacion>? _todasDonaciones;    // Donaciones globales
  Donacion? _selectedDonacion;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Donacion>? get donaciones => _donaciones;
  List<Donacion>? get todasDonaciones => _todasDonaciones;
  Donacion? get selectedDonacion => _selectedDonacion;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar TODAS las donaciones (globales)
  Future<void> loadDonaciones() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todasDonaciones = await _donacionService.getDonaciones();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar donaciones por usuario
  Future<void> loadDonacionesByUsuario(int usuarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donaciones = await _donacionService.getDonacionesByUsuario(usuarioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar donaciones por campaña
  Future<void> loadDonacionesByCampania(int campaniaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _donaciones = await _donacionService.getDonacionesByCampania(campaniaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getCantidadDonantes(int campaniaId) async {
    try {
      return await _donacionService.getCantidadDonantesPorCampania(campaniaId);
    } catch (e) {
      _error = 'Error al contar donantes: ${e.toString()}';
      return 0;
    }
  }

  // Cargar donación por ID
  Future<void> loadDonacion(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDonacion = await _donacionService.getDonacionById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear donación
  Future<bool> createDonacion(Donacion donacion) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDonacion = await _donacionService.createDonacion(donacion);

      // Agregar a ambas listas si están cargadas
      _donaciones?.add(newDonacion);
      _todasDonaciones?.add(newDonacion);

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

  // Eliminar donación
  Future<bool> deleteDonacion(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _donacionService.deleteDonacion(id);

      _donaciones?.removeWhere((d) => d.donacionId == id);
      _todasDonaciones?.removeWhere((d) => d.donacionId == id);

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
