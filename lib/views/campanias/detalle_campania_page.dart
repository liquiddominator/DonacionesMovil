import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/asignacion.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/campanias/donacion_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetalleCampaniaPage extends StatefulWidget {
  final Campania campania;

  const DetalleCampaniaPage({Key? key, required this.campania}) : super(key: key);

  @override
  State<DetalleCampaniaPage> createState() => _DetalleCampaniaPageState();
}

class _DetalleCampaniaPageState extends State<DetalleCampaniaPage> {
  List<Asignacion> _asignacionesUsuarioCampania = [];
  bool _cargandoHistorial = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarAsignacionesDelUsuario();
    });
  }

  Future<void> _cargarAsignacionesDelUsuario() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final asignacionController = Provider.of<AsignacionController>(context, listen: false);

    final usuarioId = authController.currentUser?.usuarioId;

    if (usuarioId != null) {
      final asignaciones = await asignacionController.fetchAsignacionesByUsuario(usuarioId);
      setState(() {
        _asignacionesUsuarioCampania = asignaciones
            .where((a) => a.campaniaId == widget.campania.campaniaId)
            .toList();
        _cargandoHistorial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_BO');
    final userController = Provider.of<UserController>(context, listen: false);

    final creador = userController.usuarios?.firstWhere(
      (u) => u.usuarioId == widget.campania.usuarioIdcreador,
      orElse: () => Usuario(
        usuarioId: 0,
        email: 'Desconocido',
        contrasena: '',
        nombre: '',
        apellido: '',
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.campania.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.campania.descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Meta: ${currencyFormat.format(widget.campania.metaRecaudacion)}'),
            Text('Recaudado: ${currencyFormat.format(widget.campania.montoRecaudado ?? 0)}'),
            const SizedBox(height: 8),
            Text('Inicio: ${DateFormat.yMMMd().format(widget.campania.fechaInicio)}'),
            if (widget.campania.fechaFin != null)
              Text('Fin: ${DateFormat.yMMMd().format(widget.campania.fechaFin!)}'),
            const SizedBox(height: 8),
            Text(
              'Estado: ${widget.campania.activa == true ? 'Activa' : 'Inactiva'}',
              style: TextStyle(
                color: widget.campania.activa == true ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (creador != null)
              Text(
                'Contacto del administrador: ${creador.email}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Historial de asignaciones realizadas (transparencia)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _cargandoHistorial
                ? const Center(child: CircularProgressIndicator())
                : _asignacionesUsuarioCampania.isEmpty
                    ? const Text('No hay asignaciones realizadas por ti en esta campaña.')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _asignacionesUsuarioCampania.length,
                          itemBuilder: (context, index) {
                            final asignacion = _asignacionesUsuarioCampania[index];
                            return ListTile(
                              title: Text(asignacion.descripcion),
                              subtitle: Text(
                                'Monto: ${currencyFormat.format(asignacion.monto)}\nFecha: ${DateFormat.yMMMd().format(asignacion.fechaAsignacion ?? DateTime.now())}',
                              ),
                              leading: const Icon(Icons.receipt),
                              isThreeLine: true,
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DonacionPage(campania: widget.campania),
                    ),
                  );
                },
                icon: const Icon(Icons.volunteer_activism),
                label: const Text('Donar a esta campaña'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final url = 'https://www.unicef.org.bo/?utm_source=google&utm_medium=cpa&utm_campaign=Search-Categoria-AON-Bolivia&utm_term=Kewywords+Frase&utm_content=anuncio_texto_1&utm_source=paidsearch_google&utm_medium=cpa&&utm_term=brand&utm_content=anuncio_dinamico&utm_campaign=search&gad_source=1&gad_campaignid=22433964452&gclid=CjwKCAjw8IfABhBXEiwAxRHlsGVu1YKd7wlxpFPOR1nBbHkwolgxx40ywbY1pNewJ2B4Y_5ItO-pgxoCSVYQAvD_BwE';
                  final mensaje = '''
¡Apoya esta causa! 💚

${widget.campania.titulo}

${widget.campania.descripcion}

Meta: ${currencyFormat.format(widget.campania.metaRecaudacion)}

Dona aquí: $url
''';

                  Share.share(mensaje);
                },
                icon: const Icon(Icons.share),
                label: const Text('Compartir campaña'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
