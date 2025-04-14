import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CampaniaListPage extends StatefulWidget {
  const CampaniaListPage({Key? key}) : super(key: key);

  @override
  _CampaniaListScreenState createState() => _CampaniaListScreenState();
}

class _CampaniaListScreenState extends State<CampaniaListPage> {
  @override
  void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final controller = context.read<CampaniaController>();
    controller.loadCampanias();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campañas de Donación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CampaniaController>().loadCampanias();
            },
          ),
        ],
      ),
      body: Consumer<CampaniaController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${controller.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadCampanias(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (controller.campanias == null || controller.campanias!.isEmpty) {
            return const Center(child: Text('No hay campañas disponibles'));
          }

          return ListView.builder(
            itemCount: controller.campanias!.length,
            itemBuilder: (context, index) {
              final campania = controller.campanias![index];
              return _CampaniaCard(campania: campania);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a pantalla de creación de campaña
          // Navigator.push(context, MaterialPageRoute(builder: (_) => CreateCampaniaScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CampaniaCard extends StatelessWidget {
  final Campania campania;

  const _CampaniaCard({required this.campania, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campania.titulo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(campania.descripcion),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Meta: \$${campania.metaRecaudacion.toStringAsFixed(2)}'),
                  Text('Recaudado: \$${campania.montoRecaudado?.toStringAsFixed(2) ?? '0.00'}'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (campania.montoRecaudado ?? 0) / campania.metaRecaudacion,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${campania.activa == true ? 'Activa' : 'Inactiva'}',
                    style: TextStyle(
                      color: campania.activa == true ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    'Finaliza: ${campania.fechaFin?.toLocal().toString().split(' ')[0] ?? 'Sin fecha'}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}