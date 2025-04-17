import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/views/transparencia_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs',
    decimalDigits: 2,
  );
  
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    
    return Scaffold(
      // Eliminamos el AppBar ya que está en el navigation
      body: RefreshIndicator(
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
              ],
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(context),
                    const SizedBox(height: 24),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.campaign_outlined),
                            text: 'Campañas',
                          ),
                          Tab(
                            icon: Icon(Icons.attach_money_outlined),
                            text: 'Donaciones',
                          ),
                          Tab(
                            icon: Icon(Icons.assignment_outlined),
                            text: 'Asignaciones',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 450,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCampaniasTab(context),
                          _buildDonacionesTab(context),
                          _buildAsignacionesTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
      margin: EdgeInsets.only(bottom: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón 1
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => TransparencyPage())
              );
            },
            backgroundColor: Colors.blue,
            mini: true,
            child: Icon(Icons.campaign_outlined),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

  Widget _buildSummaryCards(BuildContext context) {
    final donacionController = context.watch<DonacionController>();
    final saldosController = context.watch<SaldosDonacionController>();
    final asignacionController = context.watch<AsignacionController>();
    
    // Calcular totales
    final totalDonaciones = donacionController.donaciones?.length ?? 0;
    
    double totalDonado = 0;
    double totalUtilizado = 0;
    
    if (saldosController.saldos != null) {
      for (var saldo in saldosController.saldos!) {
        totalDonado += saldo.montoOriginal;
        totalUtilizado += saldo.montoUtilizado ?? 0;
      }
    }
    
    final totalAsignaciones = asignacionController.asignaciones.length;
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          context,
          icon: Icons.volunteer_activism,
          title: 'Donaciones',
          value: '$totalDonaciones',
          color: Colors.blue,
        ),
        _buildSummaryCard(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Total Donado',
          value: currencyFormat.format(totalDonado),
          color: Colors.green,
        ),
        _buildSummaryCard(
          context,
          icon: Icons.approval,
          title: 'Asignaciones',
          value: '$totalAsignaciones',
          color: Colors.orange,
        ),
        _buildSummaryCard(
          context,
          icon: Icons.payments,
          title: 'Fondos Utilizados',
          value: currencyFormat.format(totalUtilizado),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaniasTab(BuildContext context) {
    final campaniaController = context.watch<CampaniaController>();
    
    if (campaniaController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (campaniaController.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${campaniaController.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    final campanias = campaniaController.campanias ?? [];
    
    if (campanias.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay campañas activas en este momento',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: campanias.length,
      itemBuilder: (context, index) {
        return _buildCampaniaCard(context, campanias[index]);
      },
    );
  }

  Widget _buildCampaniaCard(BuildContext context, Campania campania) {
    final progress = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;
    final porcentaje = (progress * 100).clamp(0, 100).toStringAsFixed(1);
    final diasRestantes = campania.fechaFin != null 
        ? campania.fechaFin!.difference(DateTime.now()).inDays 
        : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen o icono representativo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.campaign,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información de la campaña
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campania.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campania.descripcion.length > 80
                            ? '${campania.descripcion.substring(0, 80)}...'
                            : campania.descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barra de progreso
            LinearPercentIndicator(
              lineHeight: 14,
              percent: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              progressColor: progress >= 1 
                  ? Colors.green 
                  : Theme.of(context).primaryColor,
              barRadius: const Radius.circular(7),
              animation: true,
              animationDuration: 1000,
              leading: Text(
                '$porcentaje%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              center: Text(
                progress >= 1 ? '¡Meta alcanzada!' : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Detalles adicionales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currencyFormat.format(campania.montoRecaudado ?? 0)} / ${currencyFormat.format(campania.metaRecaudacion)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (diasRestantes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: diasRestantes > 10 
                          ? Colors.green[50] 
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: diasRestantes > 10 
                            ? Colors.green 
                            : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$diasRestantes días restantes',
                      style: TextStyle(
                        color: diasRestantes > 10 
                            ? Colors.green 
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonacionesTab(BuildContext context) {
    final donacionController = context.watch<DonacionController>();
    
    if (donacionController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (donacionController.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${donacionController.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    final donaciones = donacionController.donaciones ?? [];
    
    if (donaciones.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aún no has realizado donaciones',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Realiza tu primera donación para ayudar',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: donaciones.length,
      itemBuilder: (context, index) {
        return _buildDonacionItem(context, donaciones[index]);
      },
    );
  }

  Widget _buildDonacionItem(BuildContext context, Donacion donacion) {
    final fechaFormateada = donacion.fechaDonacion != null
        ? DateFormat('dd/MM/yyyy').format(donacion.fechaDonacion!)
        : 'Fecha no disponible';
    
    IconData tipoIcon;
    Color tipoColor;
    
    switch (donacion.tipoDonacion.toLowerCase()) {
      case 'monetaria':
        tipoIcon = Icons.attach_money;
        tipoColor = Colors.green;
        break;
      case 'especie':
        tipoIcon = Icons.inventory_2;
        tipoColor = Colors.blue;
        break;
      default:
        tipoIcon = Icons.category;
        tipoColor = Colors.orange;
    }
    
    String estadoTexto = 'Pendiente';
    Color estadoColor = Colors.orange;
    
    switch (donacion.estadoId) {
      case 1: // Asumiendo que 1 es "Pendiente"
        estadoTexto = 'Pendiente';
        estadoColor = Colors.orange;
        break;
      case 2: // Asumiendo que 2 es "Aprobada"
        estadoTexto = 'Confirmada';
        estadoColor = Colors.green;
        break;
      case 3: // Asumiendo que 1 es "Pendiente"
        estadoTexto = 'Asignada';
        estadoColor = Colors.orange;
        break;
      case 4: // Asumiendo que 1 es "Pendiente"
        estadoTexto = 'Utilizada';
        estadoColor = Colors.orange;
        break;
      case 5: // Asumiendo que 3 es "Rechazada"
        estadoTexto = 'Cancelada';
        estadoColor = Colors.red;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icono del tipo de donación
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: tipoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tipoIcon,
                color: tipoColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Detalles de la donación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormat.format(donacion.monto),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donacion.descripcion ?? 'Donación ${donacion.tipoDonacion}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        fechaFormateada,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Estado de la donación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: estadoColor,
                  width: 1,
                ),
              ),
              child: Text(
                estadoTexto,
                style: TextStyle(
                  color: estadoColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsignacionesTab(BuildContext context) {
    final asignacionController = context.watch<AsignacionController>();
    
    if (asignacionController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (asignacionController.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${asignacionController.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    final asignaciones = asignacionController.asignaciones;
    
    if (asignaciones.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay asignaciones registradas',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: asignaciones.length,
      itemBuilder: (context, index) {
        return _buildAsignacionItem(context, asignaciones[index]);
      },
    );
  }

  Widget _buildAsignacionItem(BuildContext context, Asignacion asignacion) {
    final fechaFormateada = asignacion.fechaAsignacion != null
        ? DateFormat('dd/MM/yyyy').format(asignacion.fechaAsignacion!)
        : 'Fecha no disponible';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icono de asignación
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Detalles de la asignación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asignación #${asignacion.asignacionId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asignacion.descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Monto
                Text(
                  currencyFormat.format(asignacion.monto),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      fechaFormateada,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (asignacion.comprobante != null)
                  TextButton(
                    onPressed: () {
                      // Ver comprobante
                    },
                    child: const Text('Ver comprobante'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}