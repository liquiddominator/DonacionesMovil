import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/mensaje_controller.dart';
import 'package:donaciones_movil/controllers/respuesta_mensaje_controller.dart';
import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatAdminPage extends StatefulWidget {
  final Usuario admin;
  final List<Mensaje> mensajes;

  const ChatAdminPage({
    Key? key,
    required this.admin,
    required this.mensajes,
  }) : super(key: key);

  @override
  State<ChatAdminPage> createState() => _ChatAdminPageState();
}

class _ChatAdminPageState extends State<ChatAdminPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Mensaje> _mensajesDonante;
  List<RespuestaMensaje> _respuestasAdmin = [];

  @override
  void initState() {
    super.initState();
    _mensajesDonante = widget.mensajes;

    Future.microtask(() async {
      final respuestaController = Provider.of<RespuestaMensajeController>(context, listen: false);
      await respuestaController.loadRespuestas();

      setState(() {
        _respuestasAdmin = respuestaController.respuestas!
            .where((r) => widget.mensajes.any((m) => m.mensajeId == r.mensajeId))
            .toList();
      });
    });
  }

  void _recargarConversacion() async {
    final respuestaController = Provider.of<RespuestaMensajeController>(context, listen: false);
    final mensajeController = Provider.of<MensajeController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);

    await mensajeController.loadMensajesByUsuario(auth.currentUser!.usuarioId);
    await respuestaController.loadRespuestas();

    final mensajesActualizados = mensajeController.mensajes!.where((mensaje) =>
        (mensaje.usuarioDestino == widget.admin.usuarioId && mensaje.usuarioOrigen == auth.currentUser!.usuarioId) ||
        (mensaje.usuarioOrigen == widget.admin.usuarioId && mensaje.usuarioDestino == auth.currentUser!.usuarioId)).toList();

    setState(() {
      _mensajesDonante = mensajesActualizados;
      _respuestasAdmin = respuestaController.respuestas!
          .where((r) => _mensajesDonante.any((m) => m.mensajeId == r.mensajeId))
          .toList();
    });
  }

  void _enviarMensaje() async {
    final contenido = _controller.text.trim();
    if (contenido.isEmpty) return;

    final auth = Provider.of<AuthController>(context, listen: false);
    final mensajeController = Provider.of<MensajeController>(context, listen: false);

    final nuevoMensaje = Mensaje(
      mensajeId: 0,
      usuarioOrigen: auth.currentUser!.usuarioId,
      usuarioDestino: widget.admin.usuarioId,
      asunto: 'Nuevo mensaje',
      contenido: contenido,
      leido: false,
      respondido: false,
      fechaEnvio: DateTime.now(),
    );

    final success = await mensajeController.createMensaje(nuevoMensaje);
    if (success) {
      setState(() {
        _mensajesDonante.add(nuevoMensaje);
        _controller.clear();
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Widget _buildBurbuja({
  required String texto,
  required bool isMine,
  required String hora,
}) {
  return Align(
    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: isMine ? const Color(0xFFF58C5B) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 0),
          bottomRight: Radius.circular(isMine ? 0 : 16),
        ),
        boxShadow: [
          if (!isMine)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            texto,
            style: TextStyle(
              color: isMine ? Colors.white : Colors.black87,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hora,
            style: TextStyle(
              fontSize: 11,
              color: isMine ? Colors.white70 : Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

  List<Widget> _construirConversacion(int currentUserId) {
    final List<Widget> burbujas = [];

    for (final mensaje in _mensajesDonante) {
      final hora = DateFormat.Hm().format(mensaje.fechaEnvio ?? DateTime.now());
      burbujas.add(_buildBurbuja(texto: mensaje.contenido, isMine: true, hora: hora));

      final respuestas = _respuestasAdmin.where((r) => r.mensajeId == mensaje.mensajeId).toList();
      respuestas.sort((a, b) => (a.fechaRespuesta ?? DateTime.now()).compareTo(b.fechaRespuesta ?? DateTime.now()));

      for (final r in respuestas) {
        final horaR = DateFormat.Hm().format(r.fechaRespuesta ?? DateTime.now());
        burbujas.add(_buildBurbuja(texto: r.contenido, isMine: false, hora: horaR));
      }
    }

    return burbujas;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthController>(context).currentUser!.usuarioId;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: Column(
        children: [
          // Encabezado personalizado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF58C5B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFFF58C5B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.admin.nombre.isNotEmpty ? widget.admin.nombre : 'Admin Sistema',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '● En línea',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _recargarConversacion,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),

          // Mensajes
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: _construirConversacion(currentUserId),
            ),
          ),

          // Input de mensaje
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _enviarMensaje,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF58C5B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}