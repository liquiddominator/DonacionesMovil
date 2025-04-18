import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/campanias/detalle_campania_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';

Widget buildCampaniaCard(
  BuildContext context,
  Campania campania,
  NumberFormat currencyFormat,
  Map<int, Usuario> usuariosMap,
) {
  final progress = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;
  final porcentaje = (progress * 100).clamp(0, 100).toStringAsFixed(1);
  final diasRestantes = campania.fechaFin != null 
      ? campania.fechaFin!.difference(DateTime.now()).inDays 
      : null;

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
    child: Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen o icono representativo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.campaign,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información de la campaña
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campania.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campania.descripcion.length > 80
                            ? '${campania.descripcion.substring(0, 80)}...'
                            : campania.descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (creador != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            'Contacto: ${creador.email}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barra de progreso
            LinearPercentIndicator(
              lineHeight: 14,
              percent: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              progressColor: progress >= 1 
                  ? Colors.green 
                  : Theme.of(context).primaryColor,
              barRadius: const Radius.circular(7),
              animation: true,
              animationDuration: 1000,
              leading: Text(
                '$porcentaje%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              center: Text(
                progress >= 1 ? '¡Meta alcanzada!' : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Detalles adicionales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currencyFormat.format(campania.montoRecaudado ?? 0)} / ${currencyFormat.format(campania.metaRecaudacion)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (diasRestantes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: diasRestantes > 10 
                          ? Colors.green[50] 
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: diasRestantes > 10 
                            ? Colors.green 
                            : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$diasRestantes días restantes',
                      style: TextStyle(
                        color: diasRestantes > 10 
                            ? Colors.green 
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
