// lib/widgets/campania/compartir_campania.dart

import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class BotonesCompartir extends StatelessWidget {
  final Campania campania;

  const BotonesCompartir({super.key, required this.campania});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSocialButton(
          assetImagePath: 'assets/what_logo.png',
          color: const Color(0xFF25D366),
          label: 'WhatsApp',
          onPressed: () {
            Share.share(_generarMensaje(campania));
          },
        ),
        _buildSocialButton(
          icon: Icons.facebook,
          color: const Color(0xFF4267B2),
          label: 'Facebook',
          onPressed: () {
            Share.share(_generarMensaje(campania));
          },
        ),
        _buildSocialButton(
          icon: Icons.ios_share,
          color: const Color(0xFF1DA1F2),
          label: 'Compartir',
          onPressed: () {
            Share.share(_generarMensaje(campania));
          },
        ),
        _buildSocialButton(
          icon: Icons.copy,
          color: const Color(0xFF5C6B73),
          label: 'Copiar',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _generarMensaje(campania)));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enlace copiado')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    String? assetImagePath,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetImagePath != null
                ? Image.asset(assetImagePath, width: 24, height: 24)
                : Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generarMensaje(Campania campania) {
    final url = 'https://www.unicef.org.bo/';
    return '''
¡Apoya esta causa! 💚
${campania.titulo}
${campania.descripcion}
Meta: ${currencyFormatter.format(campania.metaRecaudacion)}
Dona aquí: $url
''';
  }
}