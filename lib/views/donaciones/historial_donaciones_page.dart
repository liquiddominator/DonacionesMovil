import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/estado_controller.dart';
import 'package:donaciones_movil/widgets/donaciones/build_donacion_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistorialDonacionesPage extends StatefulWidget {
  const HistorialDonacionesPage({Key? key}) : super(key: key);

  @override
  State<HistorialDonacionesPage> createState() => _HistorialDonacionesPageState();
}

class _HistorialDonacionesPageState extends State<HistorialDonacionesPage> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs');

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authController = context.read<AuthController>();
    final donacionController = context.read<DonacionController>();
    final campaniaController = context.read<CampaniaController>();
    final estadoController = context.read<EstadoController>();

    final userId = authController.currentUser?.usuarioId;
    if (userId != null) {
      await Future.wait([
        donacionController.loadDonacionesByUsuario(userId),
        campaniaController.loadCampanias(),
        estadoController.loadEstados(),
      ]);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final donacionController = context.watch<DonacionController>();
    final campaniaController = context.watch<CampaniaController>();
    final estadoController = context.watch<EstadoController>();

    final donaciones = donacionController.donaciones ?? [];
    final campanias = campaniaController.campanias ?? [];
    final estados = estadoController.estados ?? [];

    final Map<int, String> campaniaNombres = {
      for (var c in campanias) c.campaniaId: c.titulo,
    };
    final Map<int, String> estadoNombres = {
      for (var e in estados) e.estadoId: e.nombre,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Donaciones'),
      ),
      body: _loading || donacionController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : donaciones.isEmpty
              ? const Center(child: Text('Aún no has realizado donaciones.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: donaciones.length,
                  itemBuilder: (context, index) {
                    final donacion = donaciones[index];
                    return BuildDonacionCard(
                      donacion: donacion,
                      campaniaNombre: campaniaNombres[donacion.campaniaId] ?? 'Campaña desconocida',
                      estadoNombre: estadoNombres[donacion.estadoId] ?? 'Desconocido',
                      currencyFormat: currencyFormat,
                    );
                  },
                ),
    );
  }
}