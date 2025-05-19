import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
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
  List<Donacion> _ultimasDonaciones = [];
  bool _cargandoDonaciones = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarUltimasDonaciones();
    });
  }

  Future<void> _cargarUltimasDonaciones() async {
    final donacionController = Provider.of<DonacionController>(context, listen: false);
    await donacionController.loadDonacionesByCampania(widget.campania.campaniaId);

    final todas = donacionController.donaciones ?? [];

    todas.sort((a, b) => (b.fechaDonacion ?? DateTime.now())
        .compareTo(a.fechaDonacion ?? DateTime.now()));

    setState(() {
      _ultimasDonaciones = todas.take(2).toList();
      _cargandoDonaciones = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Meta: ${currencyFormatter.format(widget.campania.metaRecaudacion)}'),
            Text('Recaudado: ${currencyFormatter.format(widget.campania.montoRecaudado ?? 0)}'),
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
  'Últimas donaciones realizadas a esta campaña',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
_cargandoDonaciones
    ? const Center(child: CircularProgressIndicator())
    : _ultimasDonaciones.isEmpty
        ? const Text('Aún no hay donaciones registradas.')
        : Column(
            children: _ultimasDonaciones.map((donacion) {
              final usuario = userController.usuarios?.firstWhere(
                (u) => u.usuarioId == donacion.usuarioId,
                orElse: () => Usuario(
                  usuarioId: 0,
                  email: 'Desconocido',
                  contrasena: '',
                  nombre: '',
                  apellido: '',
                ),
              );

              return ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text('Monto: ${currencyFormatter.format(donacion.monto)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha: ${DateFormat.yMMMd().format(donacion.fechaDonacion ?? DateTime.now())}'),
                    Text(
                      donacion.esAnonima == true
                          ? '(Donante anónimo)'
                          : 'Donante: ${usuario?.email ?? 'Desconocido'}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            }).toList(),
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
                  Meta: ${currencyFormatter.format(widget.campania.metaRecaudacion)}
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
