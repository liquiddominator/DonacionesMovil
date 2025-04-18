import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/mensaje_controller.dart';
import 'package:donaciones_movil/controllers/respuesta_mensaje_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/controllers/usuario_rol_controller.dart';
import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/mensajes/chat_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BandejaEntradaPage extends StatefulWidget {
  const BandejaEntradaPage({super.key});

  @override
  State<BandejaEntradaPage> createState() => _BandejaEntradaPageState();
}

class _BandejaEntradaPageState extends State<BandejaEntradaPage> {
  List<Usuario> _admins = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = Provider.of<AuthController>(context, listen: false);
      final mensajeController = Provider.of<MensajeController>(context, listen: false);
      final respuestaController = Provider.of<RespuestaMensajeController>(context, listen: false);
      final usuarioRolController = Provider.of<UsuarioRolController>(context, listen: false);
      final usuarioController = Provider.of<UserController>(context, listen: false);

      await mensajeController.loadMensajesByUsuario(auth.currentUser!.usuarioId);
      await respuestaController.loadRespuestas();
      await usuarioRolController.loadUsuariosByRolId(1);

      final relacionesAdmin = usuarioRolController.usuariosRoles ?? [];
      final usuarios = <Usuario>[];

      for (var rel in relacionesAdmin) {
        final user = await usuarioController.getUsuarioById(rel.usuarioId);
        usuarios.add(user);
      }

      setState(() {
        _admins = usuarios;
      });
    });
  }

  void _abrirChatConAdmin(Usuario admin) {
    final mensajeController = Provider.of<MensajeController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);

    final mensajesRelacionados = (mensajeController.mensajes ?? []).where((mensaje) =>
        (mensaje.usuarioDestino == admin.usuarioId && mensaje.usuarioOrigen == auth.currentUser!.usuarioId) ||
        (mensaje.usuarioOrigen == admin.usuarioId && mensaje.usuarioDestino == auth.currentUser!.usuarioId)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatAdminPage(admin: admin, mensajes: mensajesRelacionados),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mensajeController = Provider.of<MensajeController>(context);
    final respuestaController = Provider.of<RespuestaMensajeController>(context);
    final currentUserId = Provider.of<AuthController>(context, listen: false).currentUser!.usuarioId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandeja de Entrada'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Autocomplete<Usuario>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Usuario>.empty();
                return _admins.where((u) =>
                    u.email.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              displayStringForOption: (Usuario option) => option.email,
              onSelected: _abrirChatConAdmin,
              fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Buscar administrador por correo...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: mensajeController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (mensajeController.mensajes == null || mensajeController.mensajes!.isEmpty)
              ? const Center(child: Text('No tienes mensajes.'))
              : _buildListaConversaciones(
                  mensajeController.mensajes!,
                  respuestaController.respuestas ?? [],
                  currentUserId,
                ),
    );
  }

  Widget _buildListaConversaciones(List<Mensaje> mensajes, List<RespuestaMensaje> respuestas, int currentUserId) {
    final Map<int, List<dynamic>> chatsPorAdmin = {};

    for (var mensaje in mensajes) {
      final adminId = mensaje.usuarioOrigen != currentUserId
          ? mensaje.usuarioOrigen
          : mensaje.usuarioDestino;

      if (adminId != null) {
        chatsPorAdmin.putIfAbsent(adminId, () => []);
        chatsPorAdmin[adminId]!.add(mensaje);
      }
    }

    for (var respuesta in respuestas) {
      final mensajeRelacionado = mensajes.firstWhere(
        (m) => m.mensajeId == respuesta.mensajeId,
        orElse: () => Mensaje(mensajeId: 0, usuarioOrigen: 0, usuarioDestino: 0, asunto: '', contenido: ''),
      );

      if (mensajeRelacionado.mensajeId == 0) continue;

      final adminId = mensajeRelacionado.usuarioDestino;

      if (adminId != null) {
        chatsPorAdmin.putIfAbsent(adminId, () => []);
        chatsPorAdmin[adminId]!.add(respuesta);
      }
    }

    return ListView.builder(
      itemCount: chatsPorAdmin.length,
      itemBuilder: (context, index) {
        final adminId = chatsPorAdmin.keys.elementAt(index);
        final mensajesYRespuestas = chatsPorAdmin[adminId]!;

        mensajesYRespuestas.sort((a, b) {
          final fechaA = a is Mensaje ? a.fechaEnvio ?? DateTime.now() : a.fechaRespuesta ?? DateTime.now();
          final fechaB = b is Mensaje ? b.fechaEnvio ?? DateTime.now() : b.fechaRespuesta ?? DateTime.now();
          return fechaB.compareTo(fechaA);
        });

        final ultimo = mensajesYRespuestas.first;
        String texto = '';
        bool esLeido = true;

        if (ultimo is Mensaje) {
          texto = ultimo.contenido;
          esLeido = ultimo.leido ?? true;
        } else if (ultimo is RespuestaMensaje) {
          texto = ultimo.contenido;
        }

        final admin = _admins.firstWhere(
          (u) => u.usuarioId == adminId,
          orElse: () => Usuario(
            usuarioId: 0,
            email: 'Desconocido',
            contrasena: '',
            nombre: '',
            apellido: '',
          ),
        );

        return ListTile(
          leading: Icon(
            esLeido ? Icons.mark_email_read : Icons.mark_email_unread,
            color: esLeido ? Colors.grey : Colors.blue,
          ),
          title: Text(admin.email),
          subtitle: Text(
            texto.length > 40 ? '${texto.substring(0, 40)}...' : texto,
          ),
          onTap: () => _abrirChatConAdmin(admin),
        );
      },
    );
  }
}