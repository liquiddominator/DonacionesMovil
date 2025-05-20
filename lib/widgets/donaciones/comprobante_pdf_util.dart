import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

Future<void> generarComprobantePdf({
  required BuildContext context,
  required Donacion donacion,
  required Campania campania,
  required String nombreEstado,
}) async {
  final pdf = pw.Document();
  final daController = context.read<DonacionAsignacionController>();
  final asignacionController = context.read<AsignacionController>();
  final detalleController = context.read<DetalleAsignacionController>();

  final donacionAsignaciones = daController.donacionAsignaciones ?? [];
  double totalUsado = 0;

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Comprobante de uso de donación', style: pw.TextStyle(fontSize: 20)),
        pw.SizedBox(height: 16),
        pw.Text('Donación: Bs${donacion.monto.toStringAsFixed(2)}'),
        pw.Text('Campaña: ${campania.titulo}'),
        pw.Text('Estado: $nombreEstado'),
        pw.Text('Fecha: ${donacion.fechaDonacion != null ? DateFormat.yMMMd().format(donacion.fechaDonacion!) : 'N/D'}'),
        pw.SizedBox(height: 20),
        pw.Text('Asignaciones', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ...donacionAsignaciones.map((da) {
          Asignacion? asignacion;
          try {
            asignacion = asignacionController.asignaciones.firstWhere((a) => a.asignacionId == da.asignacionId);
          } catch (_) {
            asignacion = null;
          }

          final detalles = detalleController.detalles
                  ?.where((d) => d.asignacionId == da.asignacionId)
                  .toList() ??
              [];

          final subtotal = detalles.fold<double>(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));
          totalUsado += subtotal;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 10),
              pw.Text('Asignación: ${asignacion?.descripcion ?? 'Sin descripción'}'),
              pw.Text('Monto asignado: Bs${da.montoAsignado.toStringAsFixed(2)}'),
              if (asignacion?.fechaAsignacion != null)
                pw.Text('Fecha: ${DateFormat.yMMMd().format(asignacion!.fechaAsignacion!)}'),
              pw.Text('Detalles:'),
              ...detalles.map((d) {
                final sub = d.cantidad * d.precioUnitario;
                return pw.Bullet(
                  text: '${d.concepto} - ${d.cantidad} x Bs${d.precioUnitario} = Bs${sub.toStringAsFixed(2)}',
                );
              }),
              if (detalles.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    'Total: Bs${subtotal.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
            ],
          );
        }).toList(),
        pw.Divider(),
        pw.Text('Total utilizado: Bs${totalUsado.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text('Saldo disponible: Bs${(donacion.monto - totalUsado).clamp(0, donacion.monto).toStringAsFixed(2)}'),
      ],
    ),
  );
  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
