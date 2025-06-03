import 'package:flutter/material.dart';
import 'package:donaciones_movil/views/auth/register_page.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/widgets/navegacion/main_navigation_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra superior decorativa
                Align(
  alignment: Alignment.topCenter,
  child: Container(
    height: 4,
    width: 340, // ancho reducido
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
),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    children: [
                      // Logo circular
                      Image.asset(
  'assets/logo.png',
  width: 120,
  height: 120,
),

                      const SizedBox(height: 16),

                      // Título
                      const Text(
                        'TraceGive',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Transparencia en cada donación',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF787878),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bienvenida
                      const Text(
                        '¡Bienvenido de vuelta!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Inicia sesión para continuar ayudando',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF787878),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Formulario
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email
                            Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Correo electrónico',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xFF2F2F2F),
      fontSize: 14,
    ),
  ),
),
const SizedBox(height: 6),
TextFormField(
  controller: _emailController,
  style: const TextStyle(color: Color(0xFF787878)),
  decoration: InputDecoration(
    hintText: 'tu@email.com',
    hintStyle: const TextStyle(color: Color.fromARGB(255, 144, 144, 144)),
    filled: true,
    fillColor: Color.fromARGB(255, 255, 245, 241),
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
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    return null;
  },
),
                            const SizedBox(height: 16),

                            Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Contraseña',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xFF2F2F2F),
      fontSize: 14,
    ),
  ),
),
const SizedBox(height: 6),
TextFormField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  style: const TextStyle(color: Color(0xFF787878)),
  decoration: InputDecoration(
    hintText: 'Tu contraseña',
    hintStyle: const TextStyle(color: Color.fromARGB(255, 144, 144, 144)),
    filled: true,
    fillColor: Color.fromARGB(255, 255, 245, 241),
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
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Color(0xFF787878),
      ),
      onPressed: () {
        setState(() => _obscurePassword = !_obscurePassword);
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    return null;
  },
),
                            // Olvidé contraseña
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Función en desarrollo')),
                                  );
                                },
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: Color(0xFFF57C00),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Botón de inicio
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final ok = await authController.login(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                          if (ok && context.mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (_) => const MainNavigationPage()),
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
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider(thickness: 1)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'o continúa con',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF787878)),
                                  ),
                                ),
                                const Expanded(child: Divider(thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Botón de Google
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tienes cuenta?', style: TextStyle(color: Color(0xFF787878))),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              );
                            },
                            child: const Text(
                              'Regístrate aquí',
                              style: TextStyle(color: Color(0xFFF57C00)),
                            ),
                          ),
                        ],
                      ),
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
}
