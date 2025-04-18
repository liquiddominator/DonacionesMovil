import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/views/donaciones/detalle_donacion_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BuildDonacionCard extends StatelessWidget {
  final Donacion donacion;
  final String campaniaNombre;
  final String estadoNombre;
  final NumberFormat currencyFormat;

  const BuildDonacionCard({
    Key? key,
    required this.donacion,
    required this.campaniaNombre,
    required this.estadoNombre,
    required this.currencyFormat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final campaniaController = context.read<CampaniaController>();
    final Campania? campania = campaniaController.campanias?.firstWhere(
      (c) => c.campaniaId == donacion.campaniaId,
      orElse: () => Campania(
        campaniaId: 0,
        titulo: 'Desconocido',
        descripcion: '',
        fechaInicio: DateTime.now(),
        metaRecaudacion: 0,
        usuarioIdcreador: 0,
      ),
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () {
          if (campania != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleDonacionPage(
                  donacion: donacion,
                  campania: campania,
                  nombreEstado: estadoNombre,
                ),
              ),
            );
          }
        },
        leading: Icon(
          donacion.tipoDonacion == 'Monetaria' ? Icons.attach_money : Icons.card_giftcard,
          color: Colors.green,
        ),
        title: Text(currencyFormat.format(donacion.monto)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campaña: ${campania?.titulo ?? 'Desconocida'}'),
            Text('Estado: $estadoNombre'),
            Text('Tipo: ${donacion.tipoDonacion}'),
            if (donacion.descripcion?.isNotEmpty == true)
              Text('Descripción: ${donacion.descripcion}'),
            if (donacion.fechaDonacion != null)
              Text('Fecha: ${DateFormat.yMMMd().format(donacion.fechaDonacion!)}'),
          ],
        ),
      ),
    );
  }
}