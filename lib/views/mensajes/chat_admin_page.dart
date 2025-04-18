import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/mensaje_controller.dart';
import 'package:donaciones_movil/controllers/respuesta_mensaje_controller.dart';
import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:flutter/material.dart';
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
  }) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  List<Widget> _construirConversacion(int currentUserId) {
    final List<Widget> burbujas = [];

    // Combinar mensajes del donante con respuestas del admin
    for (final mensaje in _mensajesDonante) {
      burbujas.add(_buildBurbuja(texto: mensaje.contenido, isMine: true));

      final respuestas = _respuestasAdmin.where((r) => r.mensajeId == mensaje.mensajeId).toList();
      respuestas.sort((a, b) => (a.fechaRespuesta ?? DateTime.now()).compareTo(b.fechaRespuesta ?? DateTime.now()));

      for (final r in respuestas) {
        burbujas.add(_buildBurbuja(texto: r.contenido, isMine: false));
      }
    }

    return burbujas;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthController>(context).currentUser!.usuarioId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat con ${widget.admin.nombre}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              children: _construirConversacion(currentUserId),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}