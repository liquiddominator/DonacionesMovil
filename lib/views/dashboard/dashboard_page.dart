import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:donaciones_movil/widgets/dashboard/build_campanias_lista.dart';
import 'package:donaciones_movil/widgets/dashboard/build_sumary_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final currencyFormat = NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs',
    decimalDigits: 2,
  );
  
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    
    // Cargar datos iniciales
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
    
    if (authController.isAuthenticated) {
      final userId = authController.currentUser!.usuarioId;
      donacionController.loadDonacionesByUsuario(userId);
      saldosController.loadSaldos();
      asignacionController.fetchAsignacionesByUsuario(userId);
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
      
      if (authController.isAuthenticated) {
        final userId = authController.currentUser!.usuarioId;
        await donacionController.loadDonacionesByUsuario(userId);
        await saldosController.loadSaldos();
        await asignacionController.fetchAsignacionesByUsuario(userId);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar datos: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
    final apellido = usuario.apellido;
    
    final ThemeData theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Donaciones Beni',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor.withOpacity(0.7),
                            primaryColor,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, $nombre $apellido!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gracias por tu apoyo continuo',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isRefreshing)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _isRefreshing ? null : _refreshData,
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {
                    // Navegar a notificaciones
                  },
                ),
                PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, color: Colors.white),
  onSelected: (value) {
    if (value == 'logout') {
      context.read<AuthController>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false, // Elimina todo el historial de navegación
      );
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'logout',
      child: Text('Cerrar sesión'),
    ),
  ],
)

              ],
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSummaryCards(context, currencyFormat),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Campañas Destacadas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 450,
                      child: buildCampaniasLista(
                        context,
                        currencyFormat,
                        _refreshData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}