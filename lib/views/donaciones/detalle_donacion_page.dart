import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/widgets/donaciones/build_saldo_info.dart';
import 'package:donaciones_movil/widgets/donaciones/detalle_donacion_asignaciones.dart';
import 'package:donaciones_movil/widgets/donaciones/detalle_donacion_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class DetalleDonacionPage extends StatefulWidget {
  final Donacion donacion;
  final Campania campania;
  final String nombreEstado;

  const DetalleDonacionPage({
    Key? key,
    required this.donacion,
    required this.campania,
    required this.nombreEstado,
  }) : super(key: key);

  @override
  State<DetalleDonacionPage> createState() => _DetalleDonacionPageState();
}

class _DetalleDonacionPageState extends State<DetalleDonacionPage> {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs');
  bool _loadingSeguimiento = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSeguimiento());
  }

  Future<void> _loadSeguimiento() async {
  final daController = context.read<DonacionAsignacionController>();
  final saldoController = context.read<SaldosDonacionController>();
  final asignacionController = context.read<AsignacionController>();
  final detalleController = context.read<DetalleAsignacionController>();

  await daController.loadAsignacionesByDonacion(widget.donacion.donacionId);
  await saldoController.loadSaldosByDonacion(widget.donacion.donacionId);

  for (var da in daController.donacionAsignaciones ?? []) {
    await asignacionController.fetchAsignacionById(da.asignacionId);
    await detalleController.loadDetallesByAsignacion(da.asignacionId);

    final detalles = detalleController.detalles
            ?.where((d) => d.asignacionId == da.asignacionId)
            .toList() ?? [];

    final double totalUsado = detalles.fold(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));

    // Actualiza el campo montoAsignado en DonacionAsignacion
    da.montoAsignado = totalUsado;
    await daController.updateDonacionAsignacion(da);

    // Actualiza el campo monto en la asignación misma
    final asignacion = asignacionController.asignaciones
        .firstWhere((a) => a.asignacionId == da.asignacionId);
    final asignacionActualizada = Asignacion(
      asignacionId: asignacion.asignacionId,
      campaniaId: asignacion.campaniaId,
      descripcion: asignacion.descripcion,
      monto: totalUsado,
      fechaAsignacion: asignacion.fechaAsignacion,
      usuarioId: asignacion.usuarioId,
      comprobante: asignacion.comprobante,
    );
    await asignacionController.updateAsignacion(asignacionActualizada);
  }

  setState(() {
    _loadingSeguimiento = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Donación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _loadingSeguimiento
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final tieneAsignaciones =
                          context.watch<DonacionAsignacionController>().donacionAsignaciones?.isNotEmpty == true;

                      return ListView(
                        children: [
                          const Text('Detalles de tu donación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          buildDetailRow('Campaña:', widget.campania.titulo),
                          buildDetailRow('Estado:', widget.nombreEstado),
                          buildDetailRow('Monto:', currencyFormat.format(widget.donacion.monto)),
                          buildDetailRow('Tipo:', widget.donacion.tipoDonacion),
                          if (widget.donacion.descripcion?.isNotEmpty == true)
                            buildDetailRow('Descripción:', widget.donacion.descripcion!),
                          if (widget.donacion.fechaDonacion != null)
                            buildDetailRow('Fecha:', DateFormat.yMMMMd('es_BO').format(widget.donacion.fechaDonacion!)),
                          const SizedBox(height: 24),
                          const Divider(),
                          const Text('Detalles de la campaña', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          buildDetailRow('Descripción:', widget.campania.descripcion),
                          buildDetailRow('Meta:', currencyFormat.format(widget.campania.metaRecaudacion)),
                          buildDetailRow('Recaudado:', currencyFormat.format(widget.campania.montoRecaudado ?? 0)),
                          buildDetailRow('Inicio:', DateFormat.yMMMd().format(widget.campania.fechaInicio)),
                          if (widget.campania.fechaFin != null)
                            buildDetailRow('Fin:', DateFormat.yMMMd().format(widget.campania.fechaFin!)),
                          buildDetailRow('Estado:', widget.campania.activa == true ? 'Activa' : 'Inactiva'),
                          const SizedBox(height: 24),
                          const Divider(),
                          const Text('Seguimiento del uso de tu donación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          buildSaldoInfo(
                            context: context,
                            donacionId: widget.donacion.donacionId,
                            montoOriginal: widget.donacion.monto,
                            currencyFormat: currencyFormat,
                            buildDetailRow: buildDetailRow,
                          ),
                          const SizedBox(height: 12),
                          ...buildAsignacionesInfo(context: context, currencyFormat: currencyFormat),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Descargar comprobante PDF'),
                            onPressed: tieneAsignaciones ? () => _generarComprobantePdf(context) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tieneAsignaciones ? Colors.teal : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                          if (!tieneAsignaciones)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'No hay asignaciones para generar comprobante.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const Text('Gracias por tu aporte ❤️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _generarComprobantePdf(BuildContext context) async {
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
          pw.Text('Donación: Bs${widget.donacion.monto.toStringAsFixed(2)}'),
          pw.Text('Campaña: ${widget.campania.titulo}'),
          pw.Text('Estado: ${widget.nombreEstado}'),
          pw.Text('Fecha: ${widget.donacion.fechaDonacion != null ? DateFormat.yMMMd().format(widget.donacion.fechaDonacion!) : 'N/D'}'),
          pw.SizedBox(height: 20),
          pw.Text('Asignaciones', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ...donacionAsignaciones.map((da) {
            Asignacion? asignacion;
            try {//
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
          pw.Text('Saldo disponible: Bs${(widget.donacion.monto - totalUsado).clamp(0, widget.donacion.monto).toStringAsFixed(2)}'),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
