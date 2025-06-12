import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/views/campanias/donacion_page.dart';
import 'package:donaciones_movil/widgets/campania/botones_compartir.dart';
import 'package:donaciones_movil/widgets/campania/estadisticas_campania.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetalleCampaniaPage extends StatefulWidget {
  final Campania campania;

  const DetalleCampaniaPage({Key? key, required this.campania}) : super(key: key);

  @override
  State<DetalleCampaniaPage> createState() => _DetalleCampaniaPageState();
}

class _DetalleCampaniaPageState extends State<DetalleCampaniaPage> {
  List<Donacion> _ultimasDonaciones = [];
  bool _cargandoDonaciones = true;
  int _cantidadDonantes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarUltimasDonaciones();
      _cargarCantidadDonantes();
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

  _cargarCantidadDonantes() async {
  final donacionController = Provider.of<DonacionController>(context, listen: false);
  final cantidad = await donacionController.getCantidadDonantes(widget.campania.campaniaId);
  setState(() {
    _cantidadDonantes = cantidad;
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
    backgroundColor: const Color(0xFFFFF8F4),
    body: Stack(
      children: [
        Column(
          children: [
            // HEADER estilo bandeja de entrada
            // HEADER estilo bandeja de entrada con imagen incluida
            ClipRRect(
      borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(50),
      bottomRight: Radius.circular(50),
      ),
    child: SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen
          widget.campania.imagenUrl != null && widget.campania.imagenUrl!.isNotEmpty
              ? Image.network(
                widget.campania.imagenUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              )
            : Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),

        // Degradado opcional para mejorar legibilidad
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.45),
                Colors.black.withOpacity(0.2),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Contenido sobre la imagen
        Padding(
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),



            // CONTENIDO SCROLLABLE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y creador
Text(
  widget.campania.titulo,
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
),
const SizedBox(height: 4),
Text(
  'Creado por ${creador!.email}',
  style: const TextStyle(
    fontSize: 14,
    color: Colors.black54,
  ),
),
const SizedBox(height: 16),

// Progreso y meta
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      currencyFormatter.format(widget.campania.montoRecaudado ?? 0),
      style: const TextStyle(
        color: Color(0xFFF58C5B),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      'de ${currencyFormatter.format(widget.campania.metaRecaudacion)}',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
  ],
),
const SizedBox(height: 4),
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: LinearProgressIndicator(
    value: ((widget.campania.montoRecaudado ?? 0) / widget.campania.metaRecaudacion).clamp(0, 1),
    minHeight: 8,
    backgroundColor: Colors.grey.shade300,
    valueColor: const AlwaysStoppedAnimation(Color(0xFFF58C5B)),
  ),
),
const SizedBox(height: 4),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      '${(((widget.campania.montoRecaudado ?? 0) / widget.campania.metaRecaudacion) * 100).toStringAsFixed(0)}% alcanzado',
      style: const TextStyle(fontSize: 12, color: Colors.black54),
    ),
    Text(
      '${widget.campania.fechaFin != null ? widget.campania.fechaFin!.difference(DateTime.now()).inDays : 0} días restantes',
      style: const TextStyle(fontSize: 12, color: Colors.black54),
    ),
  ],
),
const SizedBox(height: 16),

// Estadísticas visuales
EstadisticasCampania(
  cantidadDonantes: _cantidadDonantes,
  diasActiva: DateTime.now().difference(widget.campania.fechaInicio).inDays,
),


const SizedBox(height: 24),

                      const Text(
                        'Descripción',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.campania.descripcion,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF2F2F2F)),
                      ),

                      const SizedBox(height: 25),
                      const Text('Últimas Donaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
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
                                    final nombre = donacion.esAnonima == true
                                        ? 'Donante Anónimo'
                                        : '${usuario?.nombre} ${usuario?.apellido}';
                                    final iniciales = donacion.esAnonima == true
                                        ? 'A'
                                        : (usuario?.nombre.isNotEmpty == true
                                            ? usuario!.nombre[0].toUpperCase()
                                            : 'U');
                                    final tiempo = donacion.fechaDonacion != null
                                        ? 'Hace ${DateTime.now().difference(donacion.fechaDonacion!).inHours} horas'
                                        : '';

                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE5D4),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: const Color(0xFFF58C5B),
                                            backgroundImage: (donacion.esAnonima == false &&
                                                    usuario?.imagenUrl != null &&
                                                    usuario!.imagenUrl!.isNotEmpty)
                                                ? NetworkImage(usuario.imagenUrl!)
                                                : null,
                                            child: (donacion.esAnonima == true ||
                                                    usuario?.imagenUrl == null ||
                                                    usuario!.imagenUrl!.isEmpty)
                                                ? Text(
                                                    iniciales,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                Text(tiempo, style: const TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            currencyFormatter.format(donacion.monto),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF58C5B)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                      const SizedBox(height: 24),
                      const Text('Compartir Campaña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      BotonesCompartir(campania: widget.campania),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // BOTÓN PERSISTENTE
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DonacionPage(campania: widget.campania),
                ),
              );
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF58C5B), Color(0xFFFFA674)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Donar Ahora',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}