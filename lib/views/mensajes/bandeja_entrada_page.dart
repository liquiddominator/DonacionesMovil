import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/mensaje_controller.dart';
import 'package:donaciones_movil/controllers/respuesta_mensaje_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/controllers/usuario_rol_controller.dart';
import 'package:donaciones_movil/models/mensaje.dart';
import 'package:donaciones_movil/models/respuesta_mensaje.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/mensajes/chat_admin_page.dart';
import 'package:donaciones_movil/widgets/mensajes/bandeja_mensaje_unico.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BandejaEntradaPage extends StatefulWidget {
  const BandejaEntradaPage({super.key});

  @override
  State<BandejaEntradaPage> createState() => _BandejaEntradaPageState();
}

class _BandejaEntradaPageState extends State<BandejaEntradaPage> {
  List<Usuario> _admins = [];

  Future<void> _refreshData() async {
    final auth = context.read<AuthController>();
    final mensajeController = context.read<MensajeController>();
    final respuestaController = context.read<RespuestaMensajeController>();
    final usuarioRolController = context.read<UsuarioRolController>();
    final usuarioController = context.read<UserController>();

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
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _refreshData();
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
      backgroundColor: const Color(0xFFFFF6F0),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 66, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF58C5B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -5,
                  top: -10,
                  child: Opacity(
                    opacity: 1,
                    child: Image.asset(
                      'assets/mensaje.png',
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mensajes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Conversaciones con administradores',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<Usuario>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable<Usuario>.empty();
                        return _admins.where((u) => u.email.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      displayStringForOption: (Usuario option) => option.email,
                      onSelected: _abrirChatConAdmin,
                      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: textController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Buscar administrador por correo...',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFFF58C5B),
              backgroundColor: const Color(0xFFFFF6F0),
              child: mensajeController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (mensajeController.mensajes == null || mensajeController.mensajes!.isEmpty)
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 150),
                            Center(child: Text('No tienes mensajes.')),
                          ],
                        )
                      : _buildListaConversaciones(
                          mensajeController.mensajes!,
                          respuestaController.respuestas ?? [],
                          currentUserId,
                        ),
            ),
          ),
        ],
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
      final mensajeRelacionado = mensajes.where((m) => m.mensajeId == respuesta.mensajeId).firstOrNull;
      if (mensajeRelacionado == null) continue;

      final adminId = mensajeRelacionado.usuarioOrigen == currentUserId
          ? mensajeRelacionado.usuarioDestino
          : mensajeRelacionado.usuarioOrigen;

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

        return ConversacionItem(
          admin: admin,
          mensajesYRespuestas: mensajesYRespuestas,
          onTap: () => _abrirChatConAdmin(admin),
        );
      },
    );
  }
}