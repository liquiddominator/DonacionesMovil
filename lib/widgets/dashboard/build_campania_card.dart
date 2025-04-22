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
  Map<int, Usuario> usuariosMap, {
  Color? cardColor,
  Color? primaryColor,
  Color? textColor,
  Color? accentColor,
}) {
  // Usar los colores del tema si no se proporcionan colores personalizados
  final themeColor = Theme.of(context).primaryColor;
  final primary = primaryColor ?? themeColor;
  
  final progress = (campania.montoRecaudado ?? 0) / campania.metaRecaudacion;
  final porcentaje = (progress * 100).clamp(0, 100).toStringAsFixed(1);
  final diasRestantes = campania.fechaFin != null 
      ? campania.fechaFin!.difference(DateTime.now()).inDays 
      : null;

  final creador = usuariosMap[campania.usuarioIdcreador];
  
  // Color para indicar estado de la campaña
  final statusColor = progress >= 1 
      ? Colors.green 
      : diasRestantes != null && diasRestantes <= 5
          ? Colors.orange
          : primary;

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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con imagen de fondo o color
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // Título de campaña superpuesto
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Text(
                    campania.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black45,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Indicador de tiempo restante
                if (diasRestantes != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: diasRestantes > 10 ? Colors.white : Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$diasRestantes días',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                Text(
                  campania.descripcion.length > 100
                      ? '${campania.descripcion.substring(0, 100)}...'
                      : campania.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey[700],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Información del creador con icono
                if (creador != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${creador.nombre} ${creador.apellido}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              creador.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 20),
                
                // Barra de progreso mejorada
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monto recaudado y meta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currencyFormat.format(campania.montoRecaudado ?? 0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          'Meta: ${currencyFormat.format(campania.metaRecaudacion)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Barra de progreso con indicador porcentual
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        LinearPercentIndicator(
                          lineHeight: 20,
                          percent: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          progressColor: statusColor,
                          barRadius: const Radius.circular(10),
                          animation: true,
                          animationDuration: 1000,
                          padding: EdgeInsets.zero,
                        ),
                        Text(
                          progress >= 1.0 ? '¡Meta alcanzada!' : '$porcentaje%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Badge con estado de la campaña
                if (progress >= 1.0 || (diasRestantes != null && diasRestantes <= 5))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: progress >= 1.0
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: progress >= 1.0 ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        progress >= 1.0
                            ? '¡Meta alcanzada!'
                            : diasRestantes == 0
                                ? '¡Último día!'
                                : '¡Solo $diasRestantes ${diasRestantes == 1 ? 'día' : 'días'} restantes!',
                        style: TextStyle(
                          color: progress >= 1.0 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}