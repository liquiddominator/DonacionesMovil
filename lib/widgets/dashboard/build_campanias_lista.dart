import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/widgets/dashboard/build_campania_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget buildCampaniasLista(
  BuildContext context,
  NumberFormat currencyFormat,
  VoidCallback onRefresh,
) {
  final campaniaController = context.watch<CampaniaController>();
  final userController = context.watch<UserController>();

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

  // Crear un mapa de usuarios por ID para acceso rápido
  final Map<int, Usuario> usuariosMap = {
  for (Usuario u in userController.usuarios ?? []) u.usuarioId: u
};


  // Ordenar por monto recaudado y tomar las 3 con más fondos
  final destacadas = List<Campania>.from(campanias)
    ..sort((a, b) => (b.montoRecaudado ?? 0).compareTo(a.montoRecaudado ?? 0));

  final top3 = destacadas.take(3).toList();

  return ListView.builder(
    padding: EdgeInsets.zero,
    itemCount: top3.length,
    itemBuilder: (context, index) {
      return buildCampaniaCard(
        context,
        top3[index],
        currencyFormat,
        usuariosMap,
      );
    },
  );
}
