import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/saldos_donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildSaldoInfo({
  required BuildContext context,
  required int donacionId,
  required double montoOriginal,
  required Widget Function(String, String) buildDetailRow,
}) {
  final saldoController = context.watch<SaldosDonacionController>();
  final detalleController = context.watch<DetalleAsignacionController>();
  final daController = context.watch<DonacionAsignacionController>();

  final saldo = saldoController.saldos?.firstWhere(
    (s) => s.donacionId == donacionId,
    orElse: () => SaldosDonacion(
      saldoId: 0,
      donacionId: donacionId,
      montoOriginal: montoOriginal,
      saldoDisponible: montoOriginal,
    ),
  );

  final donacionAsignaciones = daController.donacionAsignaciones ?? [];

  double totalUsado = 0;
  for (var da in donacionAsignaciones) {
    final detalles = detalleController.detalles
            ?.where((d) => d.asignacionId == da.asignacionId)
            .toList() ??
        [];
    totalUsado += detalles.fold(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));
  }

  final disponible = saldo!.montoOriginal - totalUsado;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildDetailRow('Monto original:', currencyFormatter.format(saldo.montoOriginal)),
      buildDetailRow('Usado:', currencyFormatter.format(totalUsado)),
      buildDetailRow('Disponible:', currencyFormatter.format(disponible < 0 ? 0 : disponible)),
    ],
  );
}
