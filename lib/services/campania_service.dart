import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/services/api/api_service.dart';
import 'package:donaciones_movil/utils/constants.dart';

class CampaniaService {
  final ApiService _apiService = ApiService();

  // Obtener todas las campañas
  Future<List<Campania>> getCampanias() async {
    final data = await _apiService.get(ApiConstants.campaniaEndpoint);
    return (data as List).map((item) => Campania.fromJson(item)).toList();
  }

  // Obtener campaña por ID
  Future<Campania> getCampaniaById(int id) async {
    final data = await _apiService.get('${ApiConstants.campaniaEndpoint}/$id');
    return Campania.fromJson(data);
  }

  // Crear campaña
  Future<Campania> createCampania(Campania campania) async {
    final data = await _apiService.post(
      ApiConstants.campaniaEndpoint,
      campania.toJson(),
    );
    return Campania.fromJson(data);
  }

  // Actualizar campaña
  Future<Campania> updateCampania(Campania campania) async {
  final data = await _apiService.put(
    '${ApiConstants.campaniaEndpoint}/${campania.campaniaId}',
    campania.toJson(),
  );

  // Si el backend devuelve 204 o sin body, data será null
  if (data == null) {
    return campania; // asumimos que se actualizó correctamente
  } else {
    return Campania.fromJson(data); // si devuelve un body, lo usamos
  }
}


  // Eliminar campaña
  Future<void> deleteCampania(int id) async {
    await _apiService.delete('${ApiConstants.campaniaEndpoint}/$id');
  }

  // Obtener campañas activas
  Future<List<Campania>> getCampaniasActivas() async {
    final allCampanias = await getCampanias();
    return allCampanias.where((c) => c.activa == true).toList();
  }
}