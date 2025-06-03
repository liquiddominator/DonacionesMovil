import 'package:flutter/material.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/models/rol.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/services/rol_service.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    final roles = await _rolService.getRoles();
    final donanteRol = roles.firstWhere(
      (rol) => rol.nombre == 'Donante',
      orElse: () => roles.first,
    );
    setState(() {
      _roles = roles;
      _selectedRolId = donanteRol.rolId;
      _isLoadingRoles = false;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra decorativa
                Container(
                  height: 4,
                  width: 340,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFFF58C5B), Color(0xFFA5D6A7)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    children: [
                      const Text('¡Únete a nuestra comunidad!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2F2F2F))),
                      const SizedBox(height: 4),
                      const Text('Crea tu cuenta y comienza a ayudar',
                          style: TextStyle(fontSize: 14, color: Color(0xFF787878))),
                      const SizedBox(height: 18),

                      // Formulario
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildGroupedField('Nombre', _nombreController, 'Tu nombre')),
                                const SizedBox(width: 12),
                                Expanded(child: _buildGroupedField('Apellido', _apellidoController, 'Tu apellido')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildGroupedField('Correo electrónico', _emailController, 'tu@email.com'),
                            const SizedBox(height: 12),
                            _buildGroupedField('Teléfono (opcional)', _telefonoController, '+591 XXXXXXXXX'),
                            const SizedBox(height: 12),
                            _buildGroupedField(
                              'Contraseña',
                              _passwordController,
                              'Mínimo 6 caracteres',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Color(0xFF787878),
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildGroupedField(
                              'Confirmar contraseña',
                              _confirmarController,
                              'Repite tu contraseña',
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Color(0xFF787878),
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirm = !_obscureConfirm);
                                },
                              ),
                            ),

                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final newUsuario = Usuario(
                                            usuarioId: 0,
                                            email: _emailController.text,
                                            contrasena: _passwordController.text,
                                            nombre: _nombreController.text,
                                            apellido: _apellidoController.text,
                                            telefono: _telefonoController.text,
                                            activo: true,
                                            fechaRegistro: DateTime.now(),
                                            imagenUrl:
                                                'https://firebasestorage.googleapis.com/v0/b/transparenciadonaciones.firebasestorage.app/o/user_default.jpg?alt=media&token=5a749ef3-8eae-495e-b5b5-07d59b0d0006',
                                          );
                                          final success = await authController.register(
                                              newUsuario, _selectedRolId!);

                                          if (success && context.mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF58C5B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: authController.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Crear mi cuenta',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Botón Google
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Image.asset('assets/logo_google.png', height: 20),
                                label: const Text(
                                  'Continuar con Google',
                                  style: TextStyle(color: Color(0xFF2F2F2F)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Colors.black12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿Ya tienes cuenta?',
                                    style: TextStyle(color: Color(0xFF787878))),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                    );
                                  },
                                  child: const Text(
                                    'Inicia sesión aquí',
                                    style: TextStyle(color: Color(0xFFF57C00)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedField(String label, TextEditingController controller, String hint,
      {bool obscureText = false, TextInputType? keyboardType, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F), fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF787878)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color.fromARGB(255, 144, 144, 144)),
            filled: true,
            fillColor: const Color.fromARGB(255, 255, 245, 241),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFFD1A8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFFD1A8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF58C5B), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            suffixIcon: suffixIcon,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Campo requerido';
            return null;
          },
        ),
      ],
    );
  }
}
