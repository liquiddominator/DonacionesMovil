import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/models/saldos_donacion.dart';
import 'package:donaciones_movil/widgets/donaciones/feedback_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_BO');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Donación')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaña: ${campania.titulo}',
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _detalle('Tipo de donación:', donacion.tipoDonacion),
            if (donacion.tipoDonacion == 'Monetaria')
              _detalle('Monto:', currencyFormat.format(donacion.monto)),
            if (donacion.tipoDonacion == 'Especie')
              _detalle('Descripción:', donacion.descripcion ?? 'Sin descripción'),
            _detalle('Anonimato:', donacion.esAnonima == true ? 'Sí' : 'No'),
            _detalle(
              'Fecha:',
              DateFormat.yMMMMd('es_BO').format(donacion.fechaDonacion ?? DateTime.now()),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
  final donacionController = context.read<DonacionController>();
  final campaniaController = context.read<CampaniaController>();
  final saldoController = context.read<SaldosDonacionController>();

  final success = await donacionController.createDonacion(donacion);

  if (success) {
    final donacionCreada = donacionController.donaciones!.last;

    if (donacion.tipoDonacion == 'Monetaria') {
      // Actualizar campaña
      final nuevaCampania = Campania(
        campaniaId: campania.campaniaId,
        titulo: campania.titulo,
        descripcion: campania.descripcion,
        fechaInicio: DateTime.parse(DateFormat('yyyy-MM-dd').format(campania.fechaInicio)),
        fechaFin: campania.fechaFin != null
            ? DateTime.parse(DateFormat('yyyy-MM-dd').format(campania.fechaFin!))
            : null,
        metaRecaudacion: campania.metaRecaudacion,
        montoRecaudado: (campania.montoRecaudado ?? 0) + donacion.monto,
        usuarioIdcreador: campania.usuarioIdcreador,
        activa: campania.activa ?? true,
        fechaCreacion: campania.fechaCreacion ?? DateTime.now(),
      );
      await campaniaController.updateCampania(nuevaCampania);

      // Crear saldo para la donación monetaria
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
        builder: (_) => FeedbackDialog(donacion: donacion),
      );
    }

    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${donacionController.error}'),
        backgroundColor: Colors.red,
      ),
    );
  }
},

                icon: const Icon(Icons.check),
                label: const Text('Confirmar Donación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: Colors.green,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titulo ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }
}
