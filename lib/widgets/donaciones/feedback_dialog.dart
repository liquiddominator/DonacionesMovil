import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/models/comentario.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/comentario_controller.dart';
import 'package:donaciones_movil/utils/currency_format.dart';

class FeedbackDialog extends StatefulWidget {
  final Donacion donacion;
  final String campaniaTitulo;

  const FeedbackDialog({
    Key? key,
    required this.donacion,
    required this.campaniaTitulo,
  }) : super(key: key);

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 0;
  final _comentarioController = TextEditingController();
  bool _isSubmitting = false;
  bool _showGracias = false;

  @override
  Widget build(BuildContext context) {
    final usuario = context.read<AuthController>().currentUser;
    final comentarioController = context.read<ComentarioController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header naranja con estrella
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF58C5B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            width: double.infinity,
            child: Column(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  _showGracias ? '¡Gracias!' : 'Califica tu experiencia',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (!_showGracias)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Tu opinión nos ayuda a mejorar',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: _showGracias
    ? Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF4E3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 36, color: Color(0xFF3EB96F)),
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Gracias por tu feedback!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tu opinión es muy valiosa',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE56B4A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tu calificación nos ayuda a mejorar nuestras campañas y brindar un mejor servicio a toda la comunidad del Beni.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E6),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: Color(0xFFF58C5B), width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu contribución hace la diferencia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cada feedback nos permite optimizar nuestras campañas para generar un mayor impacto social en nuestra región.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      )

                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.campaniaTitulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tu donación: ${currencyFormatter.format(widget.donacion.monto)}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          '¿Cómo calificarías esta campaña?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return IconButton(
                              onPressed: () {
                                setState(() => _rating = i + 1);
                              },
                              icon: Icon(
                                Icons.star,
                                size: 32,
                                color:
                                    i < _rating ? Colors.amber : Colors.grey[300],
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Comparte tu experiencia (opcional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _comentarioController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            hintText:
                                '¿Qué te pareció esta campaña? ¿Hay algo que podríamos mejorar?',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            counterText: '',
                          ),
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
  valueListenable: _comentarioController,
  builder: (context, value, _) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        '${value.text.length}/500 caracteres',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  },
),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF5F5F5F),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting || _rating == 0
                                  ? null
                                  : () async {
                                      if (usuario == null) return;

                                      setState(() => _isSubmitting = true);

                                      final comentario = Comentario(
                                        usuarioId: usuario.usuarioId,
                                        nombre:
                                            '${usuario.nombre} ${usuario.apellido}',
                                        email: usuario.email,
                                        texto: _comentarioController.text.trim(),
                                        calificacion: _rating,
                                        fechaCreacion: DateTime.now(),
                                        donacionId: widget.donacion.donacionId,
                                      );

                                      final success =
                                          await comentarioController
                                              .createComentario(comentario);

                                      if (!mounted) return;
                                      setState(() => _isSubmitting = false);

                                      if (success) {
                                        setState(() => _showGracias = true);
                                        await Future.delayed(
                                            const Duration(seconds: 3));
                                        if (mounted) Navigator.pop(context);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF58C5B),
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Enviar calificación'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}
