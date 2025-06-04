import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/widgets/dashboard/build_campania_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
Widget buildCampaniasLista(
  BuildContext context,
  VoidCallback onRefresh,
) {
  final campaniaController = context.watch<CampaniaController>();
  final userController = context.watch<UserController>();
  final donacionController = context.read<DonacionController>();
 
  if (campaniaController.isLoading || userController.isLoading) {
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
            onPressed: onRefresh,
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
 
  final Map<int, Usuario> usuariosMap = {
    for (Usuario u in userController.usuarios ?? []) u.usuarioId: u
  };
 
  final destacadas = List<Campania>.from(campanias)
    ..sort((a, b) => (b.montoRecaudado ?? 0).compareTo(a.montoRecaudado ?? 0));
 
  final top4 = destacadas.take(4).toList();
 
  return GridView.builder(
    physics: const NeverScrollableScrollPhysics(), // Evita scroll interno
    shrinkWrap: true,
    padding: const EdgeInsets.only(top: 8),
    itemCount: top4.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 16,
      childAspectRatio: 0.63, // Ajusta el alto/forma de la tarjeta
    ),
    itemBuilder: (context, index) {
      final campania = top4[index];
      return FutureBuilder<int>(
        future: donacionController.getCantidadDonantes(campania.campaniaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            );
          }
 
          final cantidadDonantes = snapshot.data ?? 0;
 
          return buildCampaniaCard(
            context,
            campania,
            usuariosMap,
            cantidadDonantes,
          );
        },
      );
    },
  );
}