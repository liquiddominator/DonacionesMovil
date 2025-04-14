import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/services/campania_service.dart';
import 'package:flutter/material.dart';

class CampaniaController extends ChangeNotifier {
  final CampaniaService _campaniaService = CampaniaService();
  
  List<Campania>? _campanias;
  Campania? _selectedCampania;
  bool _isLoading = false;
  String? _error;

  List<Campania>? get campanias => _campanias;
  Campania? get selectedCampania => _selectedCampania;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todas las campañas
  Future<void> loadCampanias() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _campanias = await _campaniaService.getCampanias();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar campañas activas
  Future<void> loadCampaniasActivas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _campanias = await _campaniaService.getCampaniasActivas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar campaña por ID
  Future<void> loadCampania(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCampania = await _campaniaService.getCampaniaById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear campaña
  Future<bool> createCampania(Campania campania) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCampania = await _campaniaService.createCampania(campania);
      
      // Agregar a la lista si ya está cargada
      if (_campanias != null) {
        _campanias!.add(newCampania);
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

  // Actualizar campaña
  Future<bool> updateCampania(Campania campania) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCampania = await _campaniaService.updateCampania(campania);
      
      // Actualizar en la lista si existe
      if (_campanias != null) {
        final index = _campanias!.indexWhere((c) => c.campaniaId == campania.campaniaId);
        if (index != -1) {
          _campanias![index] = updatedCampania;
        }
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

  // Eliminar campaña
  Future<bool> deleteCampania(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _campaniaService.deleteCampania(id);
      
      // Eliminar de la lista si existe
      if (_campanias != null) {
        _campanias!.removeWhere((c) => c.campaniaId == id);
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
}