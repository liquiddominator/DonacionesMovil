import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/widgets/donaciones/comprobante_pdf_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetalleAsignacionPage extends StatelessWidget {
  final Asignacion asignacion;
  final Donacion donacion;
  final Campania campania;
  final String nombreEstado;

  const DetalleAsignacionPage({
    super.key,
    required this.asignacion,
    required this.donacion,
    required this.campania,
    required this.nombreEstado,
  });

  @override
  Widget build(BuildContext context) {
    final detalleController = context.watch<DetalleAsignacionController>();
    final detalles = detalleController.detalles
        ?.where((d) => d.asignacionId == asignacion.asignacionId)
        .toList() ?? [];

    final double totalDetalle = detalles.fold(
        0, (sum, d) => sum + (d.cantidad * d.precioUnitario));

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Asignación")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // IMAGEN + DESCRIPCIÓN Y FECHA
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: asignacion.imagenUrl != null
                      ? Image.network(
                          asignacion.imagenUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asignacion.descripcion,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (asignacion.fechaAsignacion != null)
                        Text(
                          'Fecha: ${DateFormat.yMMMd().format(asignacion.fechaAsignacion!)}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const Text('Detalles de uso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // LISTA DE DETALLES CON IMAGEN Y DATOS
            ...detalles.map((d) {
  final subtotal = d.cantidad * d.precioUnitario;
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: d.imagenUrl != null
                ? Image.network(
                    d.imagenUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.concepto,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text('Cantidad: ${d.cantidad}', style: const TextStyle(fontSize: 13)),
                Text('Precio unitario: Bs${d.precioUnitario.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Subtotal: ${d.cantidad} × Bs${d.precioUnitario.toStringAsFixed(2)} = Bs${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}),


            if (detalles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Total detallado: ${currencyFormatter.format(totalDetalle)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Descargar comprobante PDF'),
              onPressed: () => generarComprobantePdf(
                context: context,
                asignacion: asignacion,
                donacion: donacion,
                campania: campania,
                nombreEstado: nombreEstado,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}