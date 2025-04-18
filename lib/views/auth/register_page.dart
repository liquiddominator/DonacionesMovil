import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/models/rol.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/services/rol_service.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
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
  bool _obscurePassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colores naranja refinados
    const Color primaryColor = Color(0xFFFF9800);     // Naranja principal
    const Color secondaryColor = Color(0xFFFFB74D);   // Naranja secundario
    const Color accentColor = Color(0xFFF57C00);      // Naranja oscuro para acentos
    const Color textColor = Color(0xFF424242);        // Gris oscuro para texto
    
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black38,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo que cubre toda la pantalla
          Image.asset(
            'assets/auth_fondo.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          
          // Capa de overlay semi-transparente para mejorar la legibilidad
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.45),
          ),
          
          // Contenido principal
          SafeArea(
            child: Consumer<AuthController>(
              builder: (context, authController, _) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        SizedBox(height: screenSize.height * 0.02),
                        
                        // Título con animación
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Crea tu cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 3.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtítulo
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Únete a nuestra comunidad de donaciones',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        SizedBox(height: screenSize.height * 0.04),
                        
                        // Formulario con animación
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Nombre
                                  TextFormField(
                                    controller: _nombreController,
                                    decoration: InputDecoration(
                                      labelText: 'Nombre',
                                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                      prefixIcon: Icon(Icons.person_outline, color: accentColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: accentColor, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese su nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Apellido
                                  TextFormField(
                                    controller: _apellidoController,
                                    decoration: InputDecoration(
                                      labelText: 'Apellido',
                                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                      prefixIcon: Icon(Icons.person_outline, color: accentColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: accentColor, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese su apellido';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Correo electrónico',
                                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                      prefixIcon: Icon(Icons.email_outlined, color: accentColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: accentColor, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                                  
                                  // Teléfono
                                  TextFormField(
                                    controller: _telefonoController,
                                    decoration: InputDecoration(
                                      labelText: 'Teléfono (opcional)',
                                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                      prefixIcon: Icon(Icons.phone_outlined, color: accentColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: accentColor, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Rol de usuario
                                  _isLoadingRoles
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        )
                                      : DropdownButtonFormField<int>(
                                          value: _selectedRolId,
                                          decoration: InputDecoration(
                                            labelText: 'Rol de Usuario',
                                            labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                            prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: accentColor),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: accentColor, width: 2),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: Colors.grey.shade400),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                                          dropdownColor: Colors.white,
                                          icon: Icon(Icons.arrow_drop_down, color: accentColor),
                                        ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Contraseña
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                                      prefixIcon: Icon(Icons.lock_outline, color: accentColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: accentColor, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    obscureText: _obscurePassword,
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
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Mensaje de error
                                  if (authController.error != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              authController.error!,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  // Botón de registro
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
                                                    builder: (context) => const LoginPage(),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: authController.isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Crear Cuenta',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Texto para volver a iniciar sesión
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¿Ya tienes una cuenta?',
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Iniciar Sesión',
                                          style: TextStyle(
                                            color: accentColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}