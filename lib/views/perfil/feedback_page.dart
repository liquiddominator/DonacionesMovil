import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/controllers/comentario_controller.dart';
import 'package:donaciones_movil/models/comentario.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  int _calificacion = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final comentarioController = context.read<ComentarioController>();
      comentarioController.loadComentarios();
      comentarioController.loadPromedioCalificacion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final comentarioController = context.watch<ComentarioController>();
    final usuario = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback de Usuarios'),
      ),
      body: usuario == null
          ? const Center(child: Text('Debes iniciar sesión para acceder.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromedio(comentarioController),
                  const SizedBox(height: 16),
                  _buildForm(usuario, comentarioController),
                  const Divider(height: 32),
                  const Text(
                    'Todos los comentarios:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildComentarios(comentarioController, usuario.usuarioId),
                ],
              ),
            ),
    );
  }

  Widget _buildPromedio(ComentarioController controller) {
    if (controller.promedio == null) {
      return const CircularProgressIndicator();
    }
    return Text('Promedio de calificación: ${controller.promedio!.toStringAsFixed(1)} / 5');
  }

  Widget _buildForm(Usuario authUser, ComentarioController comentarioController) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deja tu comentario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _textoController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Escribe tu comentario...',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El comentario es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _calificacion,
            decoration: const InputDecoration(
              labelText: 'Calificación (1 a 5)',
              border: OutlineInputBorder(),
            ),
            items: List.generate(5, (index) {
              final val = index + 1;
              return DropdownMenuItem(value: val, child: Text('$val'));
            }),
            onChanged: (value) {
              setState(() {
                _calificacion = value ?? 5;
              });
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final comentario = Comentario(
                  usuarioId: authUser.usuarioId,
                  nombre: '${authUser.nombre} ${authUser.apellido}',
                  email: authUser.email,
                  texto: _textoController.text.trim(),
                  calificacion: _calificacion,
                  fechaCreacion: DateTime.now(),
                );

                final success = await comentarioController.createComentario(comentario);
                if (success) {
                  _textoController.clear();
                  await comentarioController.loadComentarios(); // Refresca
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comentario enviado')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al enviar comentario')),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
          )
        ],
      ),
    );
  }

  Widget _buildComentarios(ComentarioController controller, int usuarioId) {
    final comentarios = controller.comentarios;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (comentarios == null || comentarios.isEmpty) {
      return const Text('Aún no hay comentarios.');
    }

    return Column(
      children: comentarios.map((comentario) {
        final isMine = comentario.usuarioId == usuarioId;
        return ListTile(
          title: Text(comentario.nombre),
          subtitle: Text(comentario.texto),
          trailing: isMine
    ? SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⭐ ${comentario.calificacion}', style: const TextStyle(fontSize: 12)),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Eliminar'),
                    content: const Text('¿Eliminar tu comentario?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                    ],
                  ),
                );
                if (confirm == true) {
                  print('🗑 Comentario a eliminar ID: ${comentario.id}');
                  if (comentario.id != null) {
                    final success = await context.read<ComentarioController>().deleteComentario(comentario.id!);
                    if (success) {
                      await context.read<ComentarioController>().loadComentarios();
                    }
                  } else {
                    print('❌ No se puede eliminar un comentario sin ID.');
                  }
                }
              },
            ),
          ],
        ),
      )
    : Text('⭐ ${comentario.calificacion}'),

        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }
}
