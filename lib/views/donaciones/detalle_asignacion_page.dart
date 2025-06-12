import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/widgets/donaciones/comprobante_pdf_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetalleAsignacionPage extends StatefulWidget {
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
  State<DetalleAsignacionPage> createState() => _DetalleAsignacionPageState();
}

class _DetalleAsignacionPageState extends State<DetalleAsignacionPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetalles());
  }

  Future<void> _loadDetalles() async {
    final controller = context.read<DetalleAsignacionController>();
    await controller.loadDetallesByAsignacion(widget.asignacion.asignacionId);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final detalleController = context.watch<DetalleAsignacionController>();
    final detalles = detalleController.detalles
            ?.where((d) => d.asignacionId == widget.asignacion.asignacionId)
            .toList() ??
        [];

    final double totalDetalle = detalles.fold(
        0, (sum, d) => sum + (d.cantidad * d.precioUnitario));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: Column(
        children: [
          // HEADER PERSONALIZADO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF58C5B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Asignación #ASG-${widget.asignacion.asignacionId.toString().padLeft(6, '0')}',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  currencyFormatter.format(totalDetalle),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${detalles.length} concepto${detalles.length != 1 ? 's' : ''} • ${detalles.fold<int>(0, (sum, d) => sum + d.cantidad)} unidad${detalles.fold<int>(0, (sum, d) => sum + d.cantidad) != 1 ? 'es' : ''}',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                if (widget.asignacion.fechaAsignacion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMMM yyyy', 'es_BO').format(widget.asignacion.fechaAsignacion!),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // CONTENIDO PRINCIPAL CON RECARGA
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDetalles,
                    color: const Color(0xFFF58C5B),
                    backgroundColor: Color(0xFFFFF6F0),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 24),

                        // CONTENEDOR DE DETALLES
                        _buildDetalleItems(detalles),

                        if (detalles.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'Total detallado: ${currencyFormatter.format(totalDetalle)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F2F2F),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // BOTÓN PDF
                        GestureDetector(
                          onTap: () => generarComprobantePdf(
                            context: context,
                            asignacion: widget.asignacion,
                            donacion: widget.donacion,
                            campania: widget.campania,
                            nombreEstado: widget.nombreEstado,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color(0xFFA5D6A7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Factura General',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Toque para ver el comprobante principal',
                                  style: TextStyle(fontSize: 13, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItems(List detalles) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.list_alt_rounded, color: Color(0xFFF58C5B)),
              SizedBox(width: 8),
              Text(
                'Detalles de Items',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...detalles.map<Widget>((d) {
            final subtotal = d.cantidad * d.precioUnitario;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF58C5B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: d.imagenUrl != null
                                ? Image.network(
                                    d.imagenUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        d.concepto,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF2F2F2F),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(subtotal),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFE53935),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bs. ${d.precioUnitario.toStringAsFixed(2)} c/u',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF5C6B73)),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF5C6B73),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    '${d.cantidad} ${d.cantidad == 1 ? 'unidad' : 'unidades'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}