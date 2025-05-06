import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/campanias/detalle_campania_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CampaniaListPage extends StatefulWidget {
  const CampaniaListPage({Key? key}) : super(key: key);

  @override
  _CampaniasActivasScreenState createState() => _CampaniasActivasScreenState();
}

class _CampaniasActivasScreenState extends State<CampaniaListPage> {
  final currencyFormat = NumberFormat.currency(
    symbol: 'Bs ',
    decimalDigits: 2,
    locale: 'es_BO',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final campaniaController = Provider.of<CampaniaController>(context, listen: false);
      final userController = Provider.of<UserController>(context, listen: false);

      await campaniaController.loadCampaniasActivas();
      await userController.loadUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Campañas Activas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final campaniaController = Provider.of<CampaniaController>(context, listen: false);
              await campaniaController.loadCampaniasActivas();
            },
          ),
        ],
      ),
      body: Consumer2<CampaniaController, UserController>(
        builder: (context, campaniaController, userController, _) {
          if (campaniaController.isLoading || userController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (campaniaController.campanias == null || campaniaController.campanias!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No hay campañas activas', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            );
          }

          // Convertir usuarios a un mapa para acceso rápido
          final usuariosMap = {
            for (var usuario in userController.usuarios ?? [])
              usuario.usuarioId: usuario
          };

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: campaniaController.campanias!.length,
            itemBuilder: (context, index) {
              final campania = campaniaController.campanias![index];
              final creador = usuariosMap[campania.usuarioIdcreador];
              
              // Calcular progreso
              final progress = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleCampaniaPage(campania: campania),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con color
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                campania.titulo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (campania.fechaFin != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yy').format(campania.fechaFin!),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Contenido
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Descripción
                            Text(
                              campania.descripcion.length > 70
                                  ? '${campania.descripcion.substring(0, 70)}...'
                                  : campania.descripcion,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Montos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currencyFormat.format(campania.montoRecaudado ?? 0),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: progress >= 1.0 ? Colors.green : themeColor,
                                  ),
                                ),
                                Text(
                                  'Meta: ${currencyFormat.format(campania.metaRecaudacion)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Barra de progreso
                            LinearPercentIndicator(
                              lineHeight: 12,
                              percent: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[200],
                              progressColor: progress >= 1.0 ? Colors.green : themeColor,
                              barRadius: const Radius.circular(6),
                              padding: EdgeInsets.zero,
                              animation: true,
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Creador
                            if (creador != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline, 
                                    size: 16, 
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${creador.nombre} ${creador.apellido}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}