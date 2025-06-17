import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/models/donacion_asignacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
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

  Widget _buildInfoRow(String label, String value, {
  FontWeight fontWeight = FontWeight.w500,
  Color? color,
  bool isChip = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5C6B73),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        isChip
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8EACD),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  color: color ?? const Color(0xFF2F2F2F),
                  fontWeight: fontWeight,
                ),
              ),
      ],
    ),
  );
}

double _getProgresoCampania() {
  final recaudado = widget.campania.montoRecaudado ?? 0;
  final meta = widget.campania.metaRecaudacion;
  return meta > 0 ? (recaudado / meta).clamp(0, 1) : 0;
}

List<Widget> _buildSeccionDonacion() {
  return [
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Información de la Donación',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F2F2F),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tipo de donación', widget.donacion.tipoDonacion),
          const Divider(),
          _buildInfoRow(
            'Fecha de donación',
            widget.donacion.fechaDonacion != null
                ? DateFormat('d MMMM yyyy', 'es_BO').format(widget.donacion.fechaDonacion!)
                : 'Sin fecha',
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          _buildInfoRow('Estado', widget.nombreEstado, isChip: true),
          const Divider(),
          _buildInfoRow(
            'Donación anónima',
            widget.donacion.esAnonima == true ? 'Sí' : 'No',
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _buildSeccionCampania(BuildContext context) {
  return [
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
              Icon(Icons.campaign, color: Color(0xFFF58C5B)),
              SizedBox(width: 8),
              Text(
                'Campaña Asociada',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFF58C5B)),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFFF1E5),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.campania.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.campania.descripcion,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF5C6B73)),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _getProgresoCampania(),
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFFF58C5B),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormatter.format(widget.campania.montoRecaudado ?? 0)} recaudados',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      '${(_getProgresoCampania() * 100).toStringAsFixed(0)}% de ${currencyFormatter.format(widget.campania.metaRecaudacion)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Fecha de inicio',
            DateFormat('d MMMM yyyy', 'es_BO').format(widget.campania.fechaInicio),
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          if (widget.campania.fechaFin != null)
            _buildInfoRow(
              'Fecha de fin',
              DateFormat('d MMMM yyyy', 'es_BO').format(widget.campania.fechaFin!),
              fontWeight: FontWeight.bold,
            ),
          const Divider(),
          FutureBuilder(
            future: context.read<UserController>().getUsuarioById(widget.campania.usuarioIdcreador),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                final email = snapshot.data?.email ?? 'Desconocido';
                return _buildInfoRow('Contacto del creador', email);
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    ),
  ];
}


 @override
Widget build(BuildContext context) {
  final daController = context.watch<DonacionAsignacionController>();
  final asignacionController = context.watch<AsignacionController>();
  final tieneAsignaciones = daController.donacionAsignaciones?.isNotEmpty == true;

  return Scaffold(
    backgroundColor: const Color(0xFFFFF6F0),
    body: Column(
      children: [
        // Header personalizado
        Container(
          width: double.infinity,
          height: 205,
          decoration: const BoxDecoration(
            color: Color(0xFFF58C5B),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Donación #${widget.donacion.donacionId.toString().padLeft(3, '0')}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(widget.donacion.monto),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8EACD),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.nombreEstado,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Contenido principal
        Expanded(
  child: _loadingSeguimiento
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _loadSeguimiento,
          color: const Color(0xFFF58C5B),
          backgroundColor: Color(0xFFFFF6F0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                // Sección de información de la donación
                ..._buildSeccionDonacion(),
                const SizedBox(height: 24),

                // Sección de campaña
                ..._buildSeccionCampania(context),
                const SizedBox(height: 24),

                // Sección de asignaciones
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.assignment, color: Color(0xFFF58C5B)),
                          SizedBox(width: 8),
                          Text(
                            'Asignaciones de esta Donación',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ...context
                          .watch<DonacionAsignacionController>()
                          .donacionAsignaciones!
                          .map((da) {
                        final asignacion =
                            context.read<AsignacionController>().asignaciones
                                .firstWhere(
                          (a) => a.asignacionId == da.asignacionId,
                          orElse: () => Asignacion(
                            asignacionId: da.asignacionId,
                            campaniaId: widget.campania.campaniaId,
                            descripcion: 'Sin descripción',
                            monto: da.montoAsignado,
                            usuarioId: 0,
                            fechaAsignacion: da.fechaAsignacion,
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
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6F0),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF58C5B),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: asignacion.imagenUrl != null
                                              ? Image.network(
  asignacion.imagenUrl!,
  width: 70,
  height: 70,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => Container(
    width: 70,
    height: 70,
    color: Colors.grey[300],
    child: const Icon(Icons.broken_image),
  ),
)

                                              : Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons
                                                      .image_not_supported),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      asignacion.descripcion,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF2F2F2F),
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    currencyFormatter.format(
                                                        da.montoAsignado),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFFF58C5B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                asignacion.fechaAsignacion !=
                                                        null
                                                    ? 'Asignado el ${DateFormat('d MMMM yyyy', 'es_BO').format(asignacion.fechaAsignacion!)}'
                                                    : 'Sin fecha',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
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
                          ),
                        );
                      }).toList(),

                      if (!tieneAsignaciones)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'No hay asignaciones.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total asignado de tu donación',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF5C6B73)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currencyFormatter.format(
                                context
                                    .read<DonacionAsignacionController>()
                                    .donacionAsignaciones!
                                    .fold(0.0,
                                        (sum, da) => sum + da.montoAsignado),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF58C5B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
),

      ],
    ),
  );
}
}