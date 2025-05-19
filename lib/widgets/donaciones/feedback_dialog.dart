import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/models/comentario.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/comentario_controller.dart';

class FeedbackDialog extends StatefulWidget {
  final Donacion donacion;

  const FeedbackDialog({Key? key, required this.donacion}) : super(key: key);

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 5;
  final _comentarioController = TextEditingController();
  bool _isSubmitting = false;
  bool _showGracias = false;

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthController>().currentUser;
    final comentarioController = context.read<ComentarioController>();

    return AlertDialog(
      title: _showGracias
          ? const Text('¡Gracias!')
          : const Text('¿Qué te pareció donar?'),
      content: _showGracias
          ? const Text('Gracias por tu opinión 😊')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tu donación a la campaña #${widget.donacion.campaniaId} fue confirmada.'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () => setState(() => _rating = i + 1),
                      icon: Icon(
                        Icons.star,
                        color: i < _rating ? Colors.amber : Colors.grey,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: _comentarioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Comentario (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
      actions: _showGracias
          ? []
          : [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.pop(context); // solo cerrar el diálogo
                      },
                child: const Text('Omitir'),
              ),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (usuario == null) return;

                        setState(() => _isSubmitting = true);

                        final comentario = Comentario(
                          usuarioId: usuario.usuarioId,
                          nombre: '${usuario.nombre} ${usuario.apellido}',
                          email: usuario.email,
                          texto: _comentarioController.text.trim(),
                          calificacion: _rating,
                          fechaCreacion: DateTime.now(),
                          donacionId: widget.donacion.donacionId,
                        );

                        final success = await comentarioController.createComentario(comentario);

if (!mounted) return; // ⬅️ importante

setState(() => _isSubmitting = false);

if (success) {
  if (!mounted) return; // ⬅️ importante
  setState(() => _showGracias = true);

  await Future.delayed(const Duration(seconds: 3));

  if (mounted) {
    Navigator.pop(context);
  }
}

                      },
                child: const Text('Enviar'),
              ),
            ],
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}