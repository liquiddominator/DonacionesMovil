import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/views/campanias/confirmar_donacion_page.dart';
import 'package:donaciones_movil/widgets/campania/campania_card_donacion.dart';
import 'package:donaciones_movil/widgets/campania/donacion_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonacionPage extends StatefulWidget {
  final Campania campania;

  const DonacionPage({Key? key, required this.campania}) : super(key: key);

  @override
  _DonacionPageState createState() => _DonacionPageState();
}

class _DonacionPageState extends State<DonacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoDonacion = 'Monetaria';
  bool _esAnonima = false;

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
    final usuario = authController.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
  children: [
    Column(
      children: [
        // Header visual
        Container(
          width: double.infinity,
          height: 180,
          decoration: const BoxDecoration(
            color: Color(0xFFF58C5B),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 80, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Realizar Donación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu ayuda hace la diferencia',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),

        // Scrollable content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(top: 230, bottom: 20), // espacio para el card superpuesto
                children: [
                  TipoDonacionSelector(
                    tipoSeleccionado: _tipoDonacion,
                    onChangedTipo: (nuevoTipo) {
  setState(() {
    _tipoDonacion = nuevoTipo;
    if (nuevoTipo == 'Monetaria') {
      _descripcionController.clear(); // limpiamos el campo
    }
  });
},

                    montoSeleccionado: double.tryParse(_montoController.text),
                    onMontoChanged: (monto) {
                      setState(() {
                        if (monto > 0) {
                          _montoController.text = monto.toStringAsFixed(0);
                        }
                      });
                    },
                    montoController: _montoController,
                    descripcionController: _descripcionController,
                  ),
                  const SizedBox(height: 12),
                  _buildAnonimaSwitch(),
                  const SizedBox(height: 16),
                  _buildSeguridadMensaje(),
                  const SizedBox(height: 16),
                  _buildBotonContinuar(authController.currentUser),
                ],
              ),
            ),
          ),
        ),
      ],
    ),

    // Campaña superpuesta
    Positioned(
      top: 150,
      left: 20,
      right: 20,
      child: CampaniaHeaderDonacion(campania: widget.campania),
    ),
  ],
),


    );
  }
  Widget _buildAnonimaSwitch() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFDE8DC), width: 2),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Donación Anónima',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Tu nombre no aparecerá públicamente',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        Switch(
          value: _esAnonima,
          onChanged: (value) {
            setState(() {
              _esAnonima = value;
            });
          },
          activeColor: const Color(0xFFF58C5B),
        ),
      ],
    ),
  );
}

Widget _buildSeguridadMensaje() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFB8EACD),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.lock, color: Colors.black54, size: 18),
        SizedBox(width: 8),
        Text(
          'Transacción 100% segura y protegida',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

Widget _buildBotonContinuar(usuario) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final donacion = Donacion(
            donacionId: 0,
            usuarioId: usuario?.usuarioId,
            campaniaId: widget.campania.campaniaId,
            monto: _tipoDonacion == 'Monetaria'
                ? double.parse(_montoController.text)
                : 0,
            tipoDonacion: _tipoDonacion,
            descripcion: _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
            fechaDonacion: DateTime.now(),
            estadoId: 1,
            esAnonima: _esAnonima,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmarDonacionPage(
                donacion: donacion,
                campania: widget.campania,
              ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF58C5B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Continuar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

}