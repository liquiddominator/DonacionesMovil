import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildSummaryCards(BuildContext context) {
  final donacionController = context.watch<DonacionController>();
  final saldosController = context.watch<SaldosDonacionController>();
  final asignacionController = context.watch<AsignacionController>();

  final todasDonaciones = donacionController.todasDonaciones ?? [];
  final todasAsignaciones = asignacionController.asignaciones ?? [];
  final donacionesUsuario = donacionController.donaciones ?? [];

  final totalDonado = todasDonaciones.fold<double>(
    0,
    (sum, donacion) => sum + donacion.monto,
  );

  final totalUtilizado = todasAsignaciones.fold<double>(
    0,
    (sum, asignacion) => sum + asignacion.monto,
  );

  final totalDonacionesGlobal = todasDonaciones.length;

  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: buildSummaryCard(
              icon: Icons.monetization_on_rounded,
              title: 'Total Donado',
              value: currencyFormatter.format(totalDonado),
              tagText: '+12% este mes',
              iconColor: const Color(0xFFF58C5B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildSummaryCard(
              icon: Icons.payments_outlined,
              title: 'Fondos Usados',
              value: currencyFormatter.format(totalUtilizado),
              tagText: '+2 nuevas',
              iconColor: const Color(0xFF7E57C2),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: buildSummaryCard(
          icon: Icons.volunteer_activism_rounded,
          title: 'Donaciones',
          value: '$totalDonacionesGlobal',
          tagText: 'Apoyo de todos',
          iconColor: const Color(0xFF42A5F5),
          backgroundImage: 'assets/donaciones.png',
        ),
      ),
    ],
  );
}

Widget buildSummaryCard({
  required IconData icon,
  required String title,
  required String value,
  required String tagText,
  required Color iconColor,
  String? backgroundImage, // <- nueva propiedad opcional
}) {
  return Material(
  borderRadius: BorderRadius.circular(16),
  color: Colors.transparent,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Stack(
      children: [
        if (backgroundImage != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                backgroundImage,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tagText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

}