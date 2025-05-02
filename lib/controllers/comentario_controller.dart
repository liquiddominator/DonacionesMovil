import 'package:flutter/material.dart';
import 'package:donaciones_movil/models/comentario.dart';
import 'package:donaciones_movil/services/comentario_service.dart';

class ComentarioController extends ChangeNotifier {
  final ComentarioService _service = ComentarioService();

  List<Comentario>? _comentarios;
  Comentario? _selectedComentario;
  double? _promedio;
  bool _isLoading = false;
  String? _error;

  List<Comentario>? get comentarios => _comentarios;
  Comentario? get selectedComentario => _selectedComentario;
  double? get promedio => _promedio;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadComentarios() async {
    _setLoading(true);
    try {
      _comentarios = await _service.getComentarios();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> loadComentarioById(String id) async {
    _setLoading(true);
    try {
      _selectedComentario = await _service.getComentarioById(id);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> loadComentariosByUsuario(int usuarioId) async {
    _setLoading(true);
    try {
      _comentarios = await _service.getComentariosByUsuario(usuarioId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> loadComentariosByCalificacion(int calificacion) async {
    _setLoading(true);
    try {
      _comentarios = await _service.getComentariosByCalificacion(calificacion);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<void> loadPromedioCalificacion() async {
    _setLoading(true);
    try {
      _promedio = await _service.getPromedioCalificacion();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  Future<bool> createComentario(Comentario comentario) async {
  _setLoading(true);
  try {
    final nuevo = await _service.createComentario(comentario);

if (nuevo.id != null) {
  _comentarios ??= [];
  _comentarios!.add(nuevo);
} else {
  print('⚠️ Comentario creado sin ID, no se puede agregar a la lista.');
}


    await loadPromedioCalificacion();
    notifyListeners();
    return true;
  } catch (e) {
    _setError(e.toString());
    return false;
  } finally {
    _setLoading(false);
  }
}


  Future<bool> updateComentario(String id, Comentario comentario) async {
    _setLoading(true);
    try {
      final actualizado = await _service.updateComentario(id, comentario);
      final index = _comentarios?.indexWhere((c) => c.id == id);
      if (index != null && index != -1) {
        _comentarios![index] = actualizado;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteComentario(String id) async {
    _setLoading(true);
    try {
      await _service.deleteComentario(id);
      _comentarios?.removeWhere((c) => c.id == id);
      await loadPromedioCalificacion();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadComentariosByDonacion(int donacionId) async {
    _setLoading(true);
    try {
      _comentarios = await _service.getComentariosByDonacion(donacionId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }
}
