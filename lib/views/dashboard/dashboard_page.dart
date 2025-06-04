import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:donaciones_movil/views/perfil/perfil_usuario_page.dart';
import 'package:donaciones_movil/widgets/dashboard/build_campanias_lista.dart';
import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/widgets/dashboard/build_sumary_card.dart';
import 'package:donaciones_movil/widgets/navegacion/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';

class DashboardPage extends StatefulWidget {
  final Donacion? donacionReciente;

  const DashboardPage({Key? key, this.donacionReciente}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authController = context.read<AuthController>();
    final campaniaController = context.read<CampaniaController>();
    final donacionController = context.read<DonacionController>();
    final saldosController = context.read<SaldosDonacionController>();
    final asignacionController = context.read<AsignacionController>();

    campaniaController.loadCampaniasActivas();
    donacionController.loadDonaciones();
    asignacionController.fetchAsignaciones();

    if (authController.isAuthenticated) {
      final userId = authController.currentUser!.usuarioId;
      donacionController.loadDonacionesByUsuario(userId);
      saldosController.loadSaldos();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final authController = context.read<AuthController>();
      final campaniaController = context.read<CampaniaController>();
      final donacionController = context.read<DonacionController>();
      final saldosController = context.read<SaldosDonacionController>();
      final asignacionController = context.read<AsignacionController>();

      await campaniaController.loadCampaniasActivas();
      await donacionController.loadDonaciones();
      await asignacionController.fetchAsignaciones();

      if (authController.isAuthenticated) {
        final userId = authController.currentUser!.usuarioId;
        await donacionController.loadDonacionesByUsuario(userId);
        await saldosController.loadSaldos();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar datos: $e'),
          backgroundColor: const Color(0xFFF28B82),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    if (!authController.isAuthenticated) {
      return const Center(child: Text('Por favor inicia sesión'));
    }

    final usuario = authController.currentUser!;
    final nombre = usuario.nombre;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: RefreshIndicator(
        color: const Color(0xFFF58C5B),
        backgroundColor: const Color(0xFFFFF8F4),
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  child: Container(
  decoration: const BoxDecoration(
    color: Color(0xFFF58C5B),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(36),
      bottomRight: Radius.circular(36),
    ),
  ),
  child: Stack(
    children: [
      Positioned(
  left: 300, // ligeramente a la derecha del texto
  bottom: 25, // nivelado con el texto “¡Hola!”
  child: Opacity(
    opacity: 0.70, // Marca de agua sutil
    child: Image.asset(
      'assets/dashboard.png',
      width: 90,  // tamaño pequeño y contenido
      fit: BoxFit.contain,
    ),
  ),
),


                        Positioned(
                          left: 25,
                          top: 45,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  MainNavigationPage.of(context)?.changeTab(4); // índice del tab "Perfil"
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      usuario.imagenUrl ?? '',
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'TraceGive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 25,
                          bottom: 30,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Hola, $nombre!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Gracias por tu apoyo continuo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
  child: Container(
    decoration: const BoxDecoration(
      color: Color(0xFFFFF8F4),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // <-- aquí ajustas la separación
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSummaryCards(context),
          const SizedBox(height: 32),
          _buildCampaniasDestacadasSection(context),
        ],
      ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  

  Widget _buildCampaniasDestacadasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF58C5B), Color(0xFFFF9770)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Campañas Destacadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F2F2F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        buildCampaniasLista(context, _refreshData),
      ],
    );
  }
}