import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/models/saldos_donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/widgets/donaciones/feedback_dialog.dart';
import 'package:donaciones_movil/widgets/navegacion/main_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfirmarDonacionPage extends StatelessWidget {
  final Donacion donacion;
  final Campania campania;

  const ConfirmarDonacionPage({
    Key? key,
    required this.donacion,
    required this.campania,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat("dd 'de' MMMM, yyyy", 'es_BO')
        .format(donacion.fechaDonacion ?? DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: Column(
        children: [
          // Header plano
          Container(
            width: double.infinity,
            height: 160,
            decoration: const BoxDecoration(
              color: Color(0xFFF58C5B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 12),
            child: const Column(
              children: [
                Text(
                  'Confirmar Donación',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Revisa los detalles antes de confirmar',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Imagen circular
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFFF58C5B).withOpacity(0.2),
                            backgroundImage: campania.imagenUrl != null
                                ? NetworkImage(campania.imagenUrl!)
                                : null,
                            child: campania.imagenUrl == null
                                ? const Icon(Icons.volunteer_activism, color: Color(0xFFF58C5B), size: 30)
                                : null,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            campania.titulo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (campania.fechaFin != null)
                            Text(
                              'Campaña activa hasta el ${DateFormat('d \'de\' MMMM', 'es_BO').format(campania.fechaFin!)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),

                          const SizedBox(height: 20),

                          // Monto
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF58C5B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Tu donación',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  currencyFormatter.format(donacion.monto),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          _infoRow(Icons.category, 'Tipo de donación', donacion.tipoDonacion),
                          _infoRow(
                            Icons.person_outline,
                            'Modalidad',
                            donacion.esAnonima == true ? 'Anónima' : 'Pública',
                          ),
                          _infoRow(Icons.calendar_today_outlined, 'Fecha', fechaFormateada),

                          // Método de pago solo si es monetaria
                          if (donacion.tipoDonacion == 'Monetaria')
                            _infoRow(Icons.credit_card, 'Método de pago', 'Tarjeta **** 1234'),

                          const SizedBox(height: 20),

                          if (donacion.descripcion != null &&
                              donacion.descripcion!.trim().isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFFFCBB4)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '"${donacion.descripcion}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Botón confirmar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _confirmarDonacion(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF58C5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Confirmar Donación',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Botón editar
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFF58C5B)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Editar Detalles',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF58C5B),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Seguridad
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.verified_user, size: 18, color: Colors.grey),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Tu donación es segura y será procesada de forma encriptada',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(valor, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarDonacion(BuildContext context) async {
    final donacionController = context.read<DonacionController>();
    final campaniaController = context.read<CampaniaController>();
    final saldoController = context.read<SaldosDonacionController>();

    final success = await donacionController.createDonacion(donacion);

    if (success) {
      final donacionCreada = donacionController.donaciones!.last;

      if (donacion.tipoDonacion == 'Monetaria') {
        final nuevaCampania = Campania(
          campaniaId: campania.campaniaId,
          titulo: campania.titulo,
          descripcion: campania.descripcion,
          fechaInicio: campania.fechaInicio,
          fechaFin: campania.fechaFin,
          metaRecaudacion: campania.metaRecaudacion,
          montoRecaudado: (campania.montoRecaudado ?? 0) + donacion.monto,
          usuarioIdcreador: campania.usuarioIdcreador,
          imagenUrl: campania.imagenUrl,
          activa: campania.activa ?? true,
          fechaCreacion: campania.fechaCreacion ?? DateTime.now(),
        );
        await campaniaController.updateCampania(nuevaCampania);

        final nuevoSaldo = SaldosDonacion(
          saldoId: 0,
          donacionId: donacionCreada.donacionId,
          montoOriginal: donacionCreada.monto,
          montoUtilizado: 0,
          saldoDisponible: donacionCreada.monto,
          ultimaActualizacion: DateTime.now(),
        );
        await saldoController.createSaldo(nuevoSaldo);
      }

      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => FeedbackDialog(donacion: donacion, campaniaTitulo: campania.titulo,),
        );
      }

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${donacionController.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}