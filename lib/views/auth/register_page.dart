import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/models/rol.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/services/rol_service.dart';
import 'package:donaciones_movil/views/campania_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
//
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  final RolService _rolService = RolService();
  List<Rol> _roles = [];
  int? _selectedRolId;
  bool _isLoadingRoles = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      setState(() {
        _isLoadingRoles = true;
      });
      
      final roles = await _rolService.getRoles();
      
      setState(() {
        _roles = roles;
        // Seleccionar el rol "Donante" por defecto si existe
        final donanteRol = roles.firstWhere(
          (rol) => rol.nombre == 'Donante',
          orElse: () => roles.isNotEmpty ? roles.first : Rol(rolId: 0, nombre: 'Error')
        );
        _selectedRolId = donanteRol.rolId;
        _isLoadingRoles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoles = false;
      });
      // Mostrar un mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar roles: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su apellido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingrese un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _isLoadingRoles
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          value: _selectedRolId,
                          decoration: const InputDecoration(
                            labelText: 'Rol de Usuario',
                            border: OutlineInputBorder(),
                          ),
                          items: _roles.map((Rol rol) {
                            return DropdownMenuItem<int>(
                              value: rol.rolId,
                              child: Text(rol.nombre),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              _selectedRolId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione un rol';
                            }
                            return null;
                          },
                        ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (authController.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authController.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: authController.isLoading || _isLoadingRoles || _selectedRolId == null
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              // Crear usuario con los valores del formulario
                              final newUsuario = Usuario(
                                usuarioId: 0, // El ID será asignado por la API
                                email: _emailController.text,
                                contrasena: _passwordController.text,
                                nombre: _nombreController.text,
                                apellido: _apellidoController.text,
                                telefono: _telefonoController.text.isNotEmpty
                                    ? _telefonoController.text
                                    : null,
                                activo: true,
                                fechaRegistro: DateTime.now(),
                              );

                              final success = await authController.register(
                                newUsuario, 
                                _selectedRolId!
                              );
                              
                              if (success && context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CampaniaListPage(),
                                  ),
                                );
                              }
                            }
                          },
                    child: authController.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Registrarse'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}