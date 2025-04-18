import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

Widget buildSummaryCards(BuildContext context, NumberFormat currencyFormat)
 {
    final donacionController = context.watch<DonacionController>();
    final saldosController = context.watch<SaldosDonacionController>();
    final asignacionController = context.watch<AsignacionController>();
    final authController = context.watch<AuthController>();
    final userId = authController.currentUser?.usuarioId;

final totalDonaciones = donacionController.donaciones?.length ?? 0;

double totalDonado = 0;
double totalUtilizado = 0;

if (saldosController.saldos != null) {
  for (var saldo in saldosController.saldos!) {
    totalDonado += saldo.montoOriginal;
    totalUtilizado += saldo.montoUtilizado ?? 0;
  }
}

final asignacionesUsuario = asignacionController.asignaciones
    .where((a) => a.usuarioId == userId)
    .toList();

final totalAsignaciones = asignacionesUsuario.length;


    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        buildSummaryCard(
          context,
          icon: Icons.volunteer_activism,
          title: 'Donaciones',
          value: '$totalDonaciones',
          color: Colors.blue,
        ),
        buildSummaryCard(
          context,
          icon: Icons.account_balance_wallet,
          title: 'Total Donado',
          value: currencyFormat.format(totalDonado),
          color: Colors.green,
        ),
        buildSummaryCard(
          context,
          icon: Icons.approval,
          title: 'Asignaciones',
          value: '$totalAsignaciones',
          color: Colors.orange,
        ),
        buildSummaryCard(
          context,
          icon: Icons.payments,
          title: 'Fondos Utilizados',
          value: currencyFormat.format(totalUtilizado),
          color: Colors.purple,
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