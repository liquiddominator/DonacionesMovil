import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/services/mensaje_service.dart';
import 'package:flutter/material.dart';

class MensajeController extends ChangeNotifier {
  final MensajeService _service = MensajeService();
  
  List<Mensaje>? _mensajes;
  Mensaje? _selectedMensaje;
  bool _isLoading = false;
  String? _error;

  List<Mensaje>? get mensajes => _mensajes;
  Mensaje? get selectedMensaje => _selectedMensaje;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMensajes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mensajes = await _service.getMensajes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMensajeById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedMensaje = await _service.getMensajeById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMensajesByUsuario(int usuarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mensajes = await _service.getMensajesByUsuario(usuarioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMensaje(Mensaje mensaje) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMensaje = await _service.createMensaje(mensaje);
      if (_mensajes != null) _mensajes!.add(newMensaje);
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

  Future<bool> updateMensaje(Mensaje mensaje) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMensaje = await _service.updateMensaje(mensaje);
      if (_mensajes != null) {
        final index = _mensajes!.indexWhere((m) => m.mensajeId == mensaje.mensajeId);
        if (index != -1) _mensajes![index] = updatedMensaje;
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

  Future<bool> deleteMensaje(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteMensaje(id);
      if (_mensajes != null) _mensajes!.removeWhere((m) => m.mensajeId == id);
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