import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/views/perfil/feedback_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donaciones_movil/models/usuario.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  final _formKey = GlobalKey<FormState>();//

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthController>(context, listen: false).currentUser!;
    _nombreController = TextEditingController(text: user.nombre);
    _apellidoController = TextEditingController(text: user.apellido);
    _emailController = TextEditingController(text: user.email);
    _telefonoController = TextEditingController(text: user.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios(Usuario usuarioActual) async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = Usuario(
        usuarioId: usuarioActual.usuarioId,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        email: _emailController.text,
        contrasena: usuarioActual.contrasena,
        telefono: _telefonoController.text,
        activo: usuarioActual.activo,
        fechaRegistro: usuarioActual.fechaRegistro,
      );

      final userController = Provider.of<UserController>(context, listen: false);
      final authController = Provider.of<AuthController>(context, listen: false);

      final success = await userController.updateUsuario(updatedUser);

      if (success) {
        // Opcional: actualizar el usuario logeado actual si coincide
        if (authController.currentUser?.usuarioId == updatedUser.usuarioId) {
          authController.setCurrentUser(updatedUser); // Método auxiliar
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información actualizada con éxito')),
        );

        setState(() => _editMode = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userController.error ?? 'Error al actualizar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.cancel : Icons.edit),
            onPressed: () {
              setState(() => _editMode = !_editMode);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
  children: [
    TextFormField(
      controller: _nombreController,
      decoration: const InputDecoration(labelText: 'Nombre'),
      enabled: _editMode,
      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
    ),
    TextFormField(
      controller: _apellidoController,
      decoration: const InputDecoration(labelText: 'Apellido'),
      enabled: _editMode,
      validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
    ),
    TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Correo electrónico'),
      enabled: _editMode,
      validator: (value) => value!.contains('@') ? null : 'Correo inválido',
    ),
    TextFormField(
      controller: _telefonoController,
      decoration: const InputDecoration(labelText: 'Teléfono'),
      enabled: _editMode,
    ),
    const SizedBox(height: 24),
    if (_editMode)
      ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text('Guardar cambios'),
        onPressed: () => _guardarCambios(user),
      ),
    const SizedBox(height: 32),
    const Divider(),
    const Text(
      'Opciones',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    ListTile(
      leading: const Icon(Icons.feedback_outlined),
      title: const Text('Feedback / Opinión'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FeedbackPage()),
        );
      },
    ),
    ListTile(
      leading: const Icon(Icons.lock_outline),
      title: const Text('Cambiar contraseña'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Aquí puedes conectar tu pantalla de cambio de contraseña
      },
    ),
    ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Cerrar sesión'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Provider.of<AuthController>(context, listen: false).logout();
        Navigator.pop(context); // o navegar a pantalla de login
      },
    ),
  ],
),

        ),
      ),
    );
  }
}
