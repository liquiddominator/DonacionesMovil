import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/models/donacion_asignacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/widgets/donaciones/comprobante_pdf_util.dart';
import 'package:donaciones_movil/widgets/donaciones/detalle_donacion_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'detalle_asignacion_page.dart';

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

      final double totalUsado =
          detalles.fold(0, (sum, d) => sum + (d.cantidad * d.precioUnitario));

      final asignacion = asignacionController.selectedAsignacion;
      if (asignacion == null) continue;

      final asignacionActualizada = Asignacion(
        asignacionId: asignacion.asignacionId,
        campaniaId: asignacion.campaniaId,
        descripcion: asignacion.descripcion,
        monto: totalUsado,
        fechaAsignacion: asignacion.fechaAsignacion,
        usuarioId: asignacion.usuarioId,
        comprobante: asignacion.comprobante,
        imagenUrl: asignacion.imagenUrl,
      );

      await asignacionController.updateAsignacion(asignacionActualizada);

      final daActualizada = DonacionAsignacion(
        donacionAsignacionId: da.donacionAsignacionId,
        donacionId: da.donacionId,
        asignacionId: da.asignacionId,
        montoAsignado: totalUsado,
        fechaAsignacion: da.fechaAsignacion,
      );

      await context.read<DonacionAsignacionController>().updateDonacionAsignacion(daActualizada);
    }

    setState(() {
      _loadingSeguimiento = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daController = context.watch<DonacionAsignacionController>();
    final asignacionController = context.watch<AsignacionController>();
    final tieneAsignaciones = daController.donacionAsignaciones?.isNotEmpty == true;

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
                : ListView(
                    children: [
                      const Text('Detalles de tu donación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      buildDetailRow('Campaña:', widget.campania.titulo),
                      buildDetailRow('Estado:', widget.nombreEstado),
                      buildDetailRow('Monto:', currencyFormatter.format(widget.donacion.monto)),
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
                      buildDetailRow('Meta:', currencyFormatter.format(widget.campania.metaRecaudacion)),
                      buildDetailRow('Recaudado:', currencyFormatter.format(widget.campania.montoRecaudado ?? 0)),
                      buildDetailRow('Inicio:', DateFormat.yMMMd().format(widget.campania.fechaInicio)),
                      if (widget.campania.fechaFin != null)
                        buildDetailRow('Fin:', DateFormat.yMMMd().format(widget.campania.fechaFin!)),
                      buildDetailRow('Estado:', widget.campania.activa == true ? 'Activa' : 'Inactiva'),
                      const SizedBox(height: 24),
                      const Divider(),
                      const Text('Asignaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 110, // altura reducida
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: daController.donacionAsignaciones?.length ?? 0,
                          itemBuilder: (context, index) {
                            final da = daController.donacionAsignaciones![index];
                            final asignacion = asignacionController.asignaciones.firstWhere(
                              (a) => a.asignacionId == da.asignacionId,
                              orElse: () => Asignacion(
                                asignacionId: da.asignacionId,
                                campaniaId: widget.campania.campaniaId,
                                descripcion: 'Sin descripción',
                                monto: da.montoAsignado,
                                usuarioId: 0,
                              ),
                            );

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalleAsignacionPage(
                                      asignacion: asignacion,
                                      donacion: widget.donacion,
                                      campania: widget.campania,
                                      nombreEstado: widget.nombreEstado,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Container(
                                  width: 310,
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: asignacion.imagenUrl != null
                                            ? Image.network(
                                                asignacion.imagenUrl!,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                              ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              asignacion.descripcion,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Monto asignado: ${currencyFormatter.format(da.montoAsignado)}',
                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!tieneAsignaciones)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'No hay asignaciones.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      const Divider(),
                      const Text('Gracias por tu aporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}