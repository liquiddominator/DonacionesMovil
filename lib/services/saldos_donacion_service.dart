import 'package:donaciones_movil/models/saldos_donacion.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class SaldosDonacionService {
  final ApiService _apiService = ApiService();

  Future<List<SaldosDonacion>> getSaldosDonaciones() async {
    final data = await _apiService.get(ApiConstants.saldosDonacionEndpoint);
    return (data as List).map((item) => SaldosDonacion.fromJson(item)).toList();
  }

  Future<SaldosDonacion> getSaldoDonacionById(int id) async {
    final data = await _apiService.get('${ApiConstants.saldosDonacionEndpoint}/$id');
    return SaldosDonacion.fromJson(data);
  }

  Future<List<SaldosDonacion>> getSaldosByDonacion(int donacionId) async {
    final data = await _apiService.get('${ApiConstants.saldosDonacionEndpoint}/donacion/$donacionId');
    return (data as List).map((item) => SaldosDonacion.fromJson(item)).toList();
  }

  Future<SaldosDonacion> createSaldoDonacion(SaldosDonacion saldo) async {
    final data = await _apiService.post(
      ApiConstants.saldosDonacionEndpoint,
      saldo.toJson(),
    );
    return SaldosDonacion.fromJson(data);
  }

  Future<SaldosDonacion> updateSaldoDonacion(SaldosDonacion saldo) async {
    final data = await _apiService.put(
      '${ApiConstants.saldosDonacionEndpoint}/${saldo.saldoId}',
      saldo.toJson(),
    );
    return SaldosDonacion.fromJson(data);
  }

  Future<void> deleteSaldoDonacion(int id) async {
    await _apiService.delete('${ApiConstants.saldosDonacionEndpoint}/$id');
  }
}