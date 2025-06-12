import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/campanias/detalle_campania_page.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

Widget buildCampaniaCard(
  BuildContext context,
  Campania campania,
  Map<int, Usuario> usuariosMap,
  int cantidadDonantes, {
  Color? cardColor,
  Color? primaryColor,
}) {
  final diasRestantes = campania.fechaFin != null
      ? campania.fechaFin!.difference(DateTime.now()).inDays
      : null;

  final progress = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;
  final porcentaje = (progress * 100).clamp(0, 100).toStringAsFixed(1);
  final creador = usuariosMap[campania.usuarioIdcreador];

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleCampaniaPage(campania: campania),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen superior
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: SizedBox(
              height: 120,
              child: campania.imagenUrl != null &&
                      campania.imagenUrl!.trim().isNotEmpty
                  ? Image.network(
                      campania.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF58C5B),
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 28, color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF58C5B),
                      child: const Center(
                        child: Icon(Icons.local_hospital_rounded,
                            size: 28, color: Colors.white),
                      ),
                    ),
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  campania.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F2F2F),
                  ),
                ),

                const SizedBox(height: 4),

                // Email del creador
                if (creador != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      creador.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // Progreso
                Row(
                  children: [
                    Expanded(
                      child: LinearPercentIndicator(
                        lineHeight: 6,
                        percent: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        progressColor: const Color(0xFFF58C5B),
                        barRadius: const Radius.circular(6),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$porcentaje%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Donantes y días restantes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          '$cantidadDonantes',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (diasRestantes != null)
                      Text(
                        '$diasRestantes ${diasRestantes == 1 ? 'día' : 'días'}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
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
  );
}