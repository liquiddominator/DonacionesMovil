import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/models/campania.dart';
import 'package:donaciones_movil/models/donacion.dart';
import 'package:donaciones_movil/views/campanias/confirmar_donacion_page.dart';
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
      appBar: AppBar(title: Text('Donar a ${widget.campania.titulo}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.campania.descripcion,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Tipo de donación
              DropdownButtonFormField<String>(
                value: _tipoDonacion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de donación',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Monetaria', child: Text('Monetaria')),
                  DropdownMenuItem(value: 'Especie', child: Text('En especie')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoDonacion = value!;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Monto solo si es monetaria
              if (_tipoDonacion == 'Monetaria')
                TextFormField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto a donar (Bs)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_tipoDonacion == 'Monetaria') {
                      final monto = double.tryParse(value ?? '');
                      if (monto == null || monto <= 0) {
                        return 'Ingresa un monto válido';
                      }
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 12),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional para monetaria)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_tipoDonacion == 'Especie' && (value == null || value.trim().isEmpty)) {
                    return 'La descripción es obligatoria para donaciones en especie';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              CheckboxListTile(
                title: const Text('Donar de forma anónima'),
                value: _esAnonima,
                onChanged: (value) {
                  setState(() {
                    _esAnonima = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
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
                      estadoId: 1, // Pendiente
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
                child: const Text('Continuar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}