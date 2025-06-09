import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversacionItem extends StatelessWidget {
  final Usuario admin;
  final List<dynamic> mensajesYRespuestas;
  final VoidCallback onTap;

  const ConversacionItem({
    Key? key,
    required this.admin,
    required this.mensajesYRespuestas,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color naranja = Color(0xFFF58C5B);
    const Color crema = Color(0xFFFFE5D4);
    const Color azul = Color(0xFF5C6B73);
    const Color verde = Color(0xFF68B684);

    dynamic ultimo = mensajesYRespuestas.reduce((a, b) {
      final fechaA = a is Mensaje ? a.fechaEnvio ?? DateTime(2000) : a.fechaRespuesta ?? DateTime(2000);
      final fechaB = b is Mensaje ? b.fechaEnvio ?? DateTime(2000) : b.fechaRespuesta ?? DateTime(2000);
      return fechaA.isAfter(fechaB) ? a : b;
    });

    String texto = '';
    bool esLeido = true;
    bool esRespondido = false;
    DateTime? hora;

    if (ultimo is Mensaje) {
      texto = ultimo.contenido;
      esLeido = ultimo.leido ?? true;
      esRespondido = ultimo.respondido ?? false;
      hora = ultimo.fechaEnvio;
    } else if (ultimo is RespuestaMensaje) {
      texto = ultimo.contenido;
      hora = ultimo.fechaRespuesta;
      esRespondido = true;
    }

    final horaTexto = hora != null ? DateFormat('hh:mm a').format(hora!) : '';

    String estadoTexto = '';
    Color estadoColor = Colors.grey;
    IconData estadoIcon = Icons.help_outline;

    if (!esLeido) {
      estadoTexto = 'No leído';
      estadoColor = naranja;
      estadoIcon = Icons.mark_email_unread;
    } else if (esRespondido) {
      estadoTexto = 'Respondido';
      estadoColor = verde;
      estadoIcon = Icons.reply;
    } else {
      estadoTexto = 'Leído';
      estadoColor = azul;
      estadoIcon = Icons.mark_email_read;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: naranja, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    admin.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                ),
                Text(
                  horaTexto,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: azul,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(fontSize: 12.5, color: Colors.white),
              ),
            ),
            Text(
              texto.length > 100 ? '${texto.substring(0, 100)}...' : texto,
              style: const TextStyle(color: Colors.black87, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  estadoIcon,
                  color: estadoColor,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}