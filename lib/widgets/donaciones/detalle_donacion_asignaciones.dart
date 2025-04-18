import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/detalle_asignacion.dart';

List<Widget> buildAsignacionesInfo({
  required BuildContext context,
  required NumberFormat currencyFormat,
}) {
  final daController = context.watch<DonacionAsignacionController>();
  final asignacionController = context.watch<AsignacionController>();
  final detalleController = context.watch<DetalleAsignacionController>();

  final donacionAsignaciones = daController.donacionAsignaciones ?? [];

  if (donacionAsignaciones.isEmpty) {
    return [
      const Text('No hay asignaciones registradas para esta donación.'),
    ];
  }

  return donacionAsignaciones.map((da) {
    Asignacion? asignacion;
    try {
      asignacion = asignacionController.asignaciones.firstWhere(
        (a) => a.asignacionId == da.asignacionId,
      );
    } catch (_) {
      asignacion = null;
    }

    final List<DetalleAsignacion> detalles = detalleController.detalles
            ?.where((d) => d.asignacionId == da.asignacionId)
            .toList() ??
        [];

    final double totalDetalle = detalles.fold(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asignación: ${asignacion?.descripcion ?? 'Sin descripción'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Monto asignado desde esta donación: ${currencyFormat.format(da.montoAsignado)}'),
            if (asignacion?.fechaAsignacion != null)
              Text('Fecha de asignación: ${DateFormat.yMMMd().format(asignacion!.fechaAsignacion!)}'),
            const SizedBox(height: 8),
            const Text('Detalles de uso:'),
            ...detalles.map((d) {
              final subtotal = d.precioUnitario * d.cantidad;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '- ${d.concepto} × ${d.cantidad} @ Bs${d.precioUnitario.toStringAsFixed(2)} → Bs${subtotal.toStringAsFixed(2)}',
                ),
              );
            }),
            if (detalles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Total detallado: ${currencyFormat.format(totalDetalle)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }).toList();
}
