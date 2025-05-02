import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

Widget buildSummaryCards(BuildContext context, NumberFormat currencyFormat) {
  final donacionController = context.watch<DonacionController>();
  final saldosController = context.watch<SaldosDonacionController>();
  final asignacionController = context.watch<AsignacionController>();
  final authController = context.watch<AuthController>();

  // ✅ Donaciones globales
  final todasDonaciones = donacionController.todasDonaciones ?? [];

  // ✅ Asignaciones globales
  final todasAsignaciones = asignacionController.asignaciones ?? [];

  // ✅ Total donado por todos los usuarios
  final totalDonado = todasDonaciones.fold<double>(
    0,
    (sum, donacion) => sum + donacion.monto,
  );

  // ✅ Total utilizado (fondos asignados)
  final totalUtilizado = todasAsignaciones.fold<double>(
    0,
    (sum, asignacion) => sum + asignacion.monto,
  );

  // ✅ Cantidad de donaciones del usuario actual
  final donacionesUsuario = donacionController.donaciones ?? [];
  final totalDonacionesUsuario = donacionesUsuario.length;

  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: buildSummaryCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Total Donado',
              value: currencyFormat.format(totalDonado),
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: buildSummaryCard(
              context,
              icon: Icons.payments,
              title: 'Fondos Utilizados',
              value: currencyFormat.format(totalUtilizado),
              color: Colors.purple,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: buildSummaryCard(
          context,
          icon: Icons.volunteer_activism,
          title: 'Donaciones',
          value: '$totalDonacionesUsuario',
          color: Colors.blue,
        ),
      ),
    ],
  );
}

Widget buildSummaryCard(
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
