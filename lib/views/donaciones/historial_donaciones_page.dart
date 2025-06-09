import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/estado_controller.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/widgets/donaciones/build_donacion_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorialDonacionesPage extends StatefulWidget {
  const HistorialDonacionesPage({Key? key}) : super(key: key);

  @override
  State<HistorialDonacionesPage> createState() => _HistorialDonacionesPageState();
}

class _HistorialDonacionesPageState extends State<HistorialDonacionesPage> {
  bool _loading = true;
  String _activeFilter = 'Todas';

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
        donacionController.loadDonaciones(),
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

    final donacionesFiltradas = _activeFilter == 'Todas'
    ? donaciones
    : donaciones.where((d) => d.tipoDonacion.toLowerCase() == _activeFilter.toLowerCase()).toList();

    final totalDonado = donaciones.fold<double>(
  0,
  (sum, d) => sum + d.monto,
);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: _loading || donacionController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con degradado y título
                    Container(
  width: double.infinity,
  height: 170,
  decoration: const BoxDecoration(
    color: Color(0xFFF58C5B),
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
  ),
  child: Stack(
    children: [
      // Imagen de fondo posicionada libremente
      Positioned(
        right:  10,
        bottom: -12,
        child: Opacity(
          opacity: 1,
          child: Image.asset(
            'assets/listaDonacion.png',
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
      ),
      // Contenido textual encima de la imagen
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 56, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Text(
              'Mis Donaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Historial de contribuciones',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    ],
  ),
),
                    const SizedBox(height: 100), // Espacio para el card superpuesto
                    // Filtros
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterChip('Todas'),
                            _buildFilterChip('Monetaria'),
                            _buildFilterChip('Especie'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Lista de donaciones
                    Expanded(
  child: RefreshIndicator(
    onRefresh: _loadData,
    color: const Color(0xFFF58C5B),
    backgroundColor: const Color(0xFFFFF6F0),
    child: ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: donacionesFiltradas.length,
      itemBuilder: (context, index) {
        final donacion = donacionesFiltradas[index];
        return BuildDonacionCard(
          donacion: donacion,
          campaniaNombre:
              campaniaNombres[donacion.campaniaId] ?? 'Campaña desconocida',
          estadoNombre:
              estadoNombres[donacion.estadoId] ?? 'Estado desconocido',
        );
      },
    ),
  ),
),

                  ],
                ),
                
                // Card de estadísticas superpuesto
                Positioned(
                  top: 140, // Ajusta esta posición según necesites
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildResumenBox('Total Donaciones', '${donaciones.length}'),
                        const SizedBox(width: 12),
                        _buildResumenBox('Monto Total', currencyFormatter.format(totalDonado)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildResumenBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE5D4), // fondo crema
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFFF58C5B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;

    return GestureDetector(
      onTap: () => setState(() {
        _activeFilter = label;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF58C5B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF7A7A7A),
          ),
        ),
      ),
    );
  }
}