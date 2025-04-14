import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/services/respuesta_mensaje_service.dart';
import 'package:flutter/material.dart';

class RespuestaMensajeController extends ChangeNotifier {
  final RespuestaMensajeService _service = RespuestaMensajeService();
  
  List<RespuestaMensaje>? _respuestas;
  RespuestaMensaje? _selectedRespuesta;
  bool _isLoading = false;
  String? _error;

  List<RespuestaMensaje>? get respuestas => _respuestas;
  RespuestaMensaje? get selectedRespuesta => _selectedRespuesta;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRespuestas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _respuestas = await _service.getRespuestas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRespuestaById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRespuesta = await _service.getRespuestaById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRespuestasByMensaje(int mensajeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _respuestas = await _service.getRespuestasByMensaje(mensajeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRespuesta(RespuestaMensaje respuesta) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRespuesta = await _service.createRespuesta(respuesta);
      if (_respuestas != null) _respuestas!.add(newRespuesta);
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

  Future<bool> deleteRespuesta(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteRespuesta(id);
      if (_respuestas != null) _respuestas!.removeWhere((r) => r.respuestaId == id);
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