import 'package:flutter/material.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/utils/currency_format.dart';

class CampaniaHeaderDonacion extends StatelessWidget {
  final Campania campania;

  const CampaniaHeaderDonacion({super.key, required this.campania});

  @override
  Widget build(BuildContext context) {
    final double progreso = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte superior: fondo naranja con imagen como fondo (solo si hay imagen)
          if (campania.imagenUrl != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF58C5B),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(campania.imagenUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Contenido inferior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campania.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2F2F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campania.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF787878),
                  ),
                ),
                const SizedBox(height: 12),

                // Barra de progreso
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progreso.clamp(0, 1),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF58C5B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Recaudado y meta
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currencyFormatter.format(campania.montoRecaudado ?? 0)} recaudados',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787878),
                      ),
                    ),
                    Text(
                      'Meta: ${currencyFormatter.format(campania.metaRecaudacion)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF787878),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}