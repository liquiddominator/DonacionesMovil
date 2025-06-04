import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/campanias/detalle_campania_page.dart';

class CampaniaCard extends StatelessWidget {
  final Campania campania;
  final Usuario? creador;
  final NumberFormat currencyFormat;

  const CampaniaCard({
    super.key,
    required this.campania,
    required this.creador,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleCampaniaPage(campania: campania),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen o ícono con fondo degradado
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE0B2), Color(0xFFFFCCBC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: campania.imagenUrl != null && campania.imagenUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          campania.imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 30),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.local_hospital_rounded, size: 28, color: Colors.black87),
                      ),
              ),
              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campania.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: Color(0xFF2F2F2F),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campania.descripcion.length > 60
                          ? '${campania.descripcion.substring(0, 60)}...'
                          : campania.descripcion,
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 13.3,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Barra de progreso
                    LinearPercentIndicator(
                      lineHeight: 6,
                      percent: progress.clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFF0F0F0),
                      progressColor: const Color.fromARGB(255, 246, 161, 116), // verde suave
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                      animation: true,
                    ),
                    const SizedBox(height: 6),

                    // % completado
                    Text(
                      '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% completado',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                    ),

                    const SizedBox(height: 6),

                    // Recaudado vs Meta + Estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bs ${currencyFormat.format(campania.montoRecaudado ?? 0)} / Bs ${currencyFormat.format(campania.metaRecaudacion)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
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
    );
  }
}