import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/views/donaciones/detalle_donacion_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BuildDonacionCard extends StatelessWidget {
  final Donacion donacion;
  final String campaniaNombre;
  final String estadoNombre;

  const BuildDonacionCard({
    Key? key,
    required this.donacion,
    required this.campaniaNombre,
    required this.estadoNombre,
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

    if (donacion.tipoDonacion == 'Monetaria') {
      return _buildDonacionMonetaria(context, campania);
    } else {
      return _buildDonacionEspecie(context, campania);
    }
  }

  Widget _buildDonacionMonetaria(BuildContext context, Campania? campania) {
  final progreso = (campania?.montoRecaudado ?? 0) / (campania?.metaRecaudacion == 0 ? 1 : campania!.metaRecaudacion);

  return GestureDetector(
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
  child: Container(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border(
        left: BorderSide(
          color: const Color(0xFFF58C5B),
          width: 4,
        ),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14), // padding más compacto
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono + número de donación + estado
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'Donación #${donacion.donacionId.toString().padLeft(3, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0F0D4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estadoNombre,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Monto
          Text(
            currencyFormatter.format(donacion.monto),
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFFF58C5B),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Fecha
          if (donacion.fechaDonacion != null)
            Text(
              DateFormat('d \'de\' MMMM, y', 'es').format(donacion.fechaDonacion!),
              style: const TextStyle(color: Colors.grey),
            ),

          const Divider(height: 24),

          // Tipo de donación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD0F0D4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Monetaria',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),

          const SizedBox(height: 16),

          // Información de campaña y progreso
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.campaign, size: 20, color: Color(0xFFF58C5B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        campania?.titulo ?? 'Campaña desconocida',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${currencyFormatter.format(campania?.montoRecaudado ?? 0)} de ${currencyFormatter.format(campania?.metaRecaudacion ?? 1)} recaudados',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progreso > 1 ? 1 : progreso,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFFF58C5B),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

}


  Widget _buildDonacionEspecie(BuildContext context, Campania? campania) {
  return GestureDetector(
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
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: const Color(0xFF5C6B73), // Gris oscuro
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono + número de donación + estado
            Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, color: Color(0xFF5C6B73)), // ícono de ayuda
                const SizedBox(width: 6),
                Text(
                  'Donación #${donacion.donacionId.toString().padLeft(3, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0F0D4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estadoNombre,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ],
            ),

            const SizedBox(height: 12),

            // Descripción (en lugar del monto)
            Text(
              donacion.descripcion?.isNotEmpty == true
                  ? donacion.descripcion!
                  : 'Sin descripción',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F2F2F),
              ),
            ),

            const SizedBox(height: 4),

            // Fecha
            if (donacion.fechaDonacion != null)
              Text(
                DateFormat('d \'de\' MMMM, y', 'es').format(donacion.fechaDonacion!),
                style: const TextStyle(color: Colors.grey),
              ),

            const Divider(height: 24),

            // Tipo de donación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'En Especie',
                style: TextStyle(color: Color(0xFF5C6B73), fontSize: 12),
              ),
            ),

            const SizedBox(height: 16),

            // Información de campaña (sin barra de progreso)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, size: 20, color: Color(0xFFF58C5B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      campania?.titulo ?? 'Campaña desconocida',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}