import 'package:donaciones_movil/models/saldos_donacion.dart';
import 'package:donaciones_movil/services/saldos_donacion_service.dart';
import 'package:flutter/material.dart';

class SaldosDonacionController extends ChangeNotifier {
  final SaldosDonacionService _service = SaldosDonacionService();
  
  List<SaldosDonacion>? _saldos;
  SaldosDonacion? _selectedSaldo;
  bool _isLoading = false;
  String? _error;

  List<SaldosDonacion>? get saldos => _saldos;
  SaldosDonacion? get selectedSaldo => _selectedSaldo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSaldos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _saldos = await _service.getSaldosDonaciones();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSaldoById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSaldo = await _service.getSaldoDonacionById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSaldosByDonacion(int donacionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _saldos = await _service.getSaldosByDonacion(donacionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSaldo(SaldosDonacion saldo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSaldo = await _service.createSaldoDonacion(saldo);
      if (_saldos != null) _saldos!.add(newSaldo);
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

  Future<bool> updateSaldo(SaldosDonacion saldo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedSaldo = await _service.updateSaldoDonacion(saldo);
      if (_saldos != null) {
        final index = _saldos!.indexWhere((s) => s.saldoId == saldo.saldoId);
        if (index != -1) _saldos![index] = updatedSaldo;
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

  Future<bool> deleteSaldo(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteSaldoDonacion(id);
      if (_saldos != null) _saldos!.removeWhere((s) => s.saldoId == id);
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