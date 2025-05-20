import 'dart:typed_data';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  bool _editMode = false;
  bool _isLoading = false;

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
      setState(() => _isLoading = true);

      final updatedUser = Usuario(
        usuarioId: usuarioActual.usuarioId,
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        email: _emailController.text,
        contrasena: usuarioActual.contrasena,
        telefono: _telefonoController.text,
        activo: usuarioActual.activo,
        fechaRegistro: usuarioActual.fechaRegistro,
        imagenUrl: usuarioActual.imagenUrl,
      );

      final userController = Provider.of<UserController>(context, listen: false);
      final authController = Provider.of<AuthController>(context, listen: false);

      try {
        final success = await userController.updateUsuario(updatedUser);

        if (success) {
          if (authController.currentUser?.usuarioId == updatedUser.usuarioId) {
            authController.setCurrentUser(updatedUser);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Información actualizada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _editMode = false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userController.error ?? 'Error al actualizar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seleccionarYSubirImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final authController = Provider.of<AuthController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);
    final usuarioActual = authController.currentUser!;

    if (pickedFile != null) {
      setState(() => _isLoading = true);

      try {
        final fileName = path.basename(pickedFile.path);
        final storageRef = FirebaseStorage.instance.ref().child('usuarios/$fileName');
        final uploadTask = await storageRef.putData(await pickedFile.readAsBytes());
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        final updatedUser = Usuario(
          usuarioId: usuarioActual.usuarioId,
          nombre: usuarioActual.nombre,
          apellido: usuarioActual.apellido,
          email: usuarioActual.email,
          contrasena: usuarioActual.contrasena,
          telefono: usuarioActual.telefono,
          activo: usuarioActual.activo,
          fechaRegistro: usuarioActual.fechaRegistro,
          imagenUrl: downloadUrl,
        );

        final success = await userController.updateUsuario(updatedUser);
        if (success) authController.setCurrentUser(updatedUser);

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Imagen actualizada'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;
    if (user == null) {
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        centerTitle: true,
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: Icon(_editMode ? Icons.close : Icons.edit),
                  tooltip: _editMode ? 'Cancelar edición' : 'Editar perfil',
                  onPressed: () => setState(() => _editMode = !_editMode),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: user.imagenUrl != null && user.imagenUrl!.isNotEmpty
                                ? NetworkImage(user.imagenUrl!)
                                : null,
                            child: (user.imagenUrl == null || user.imagenUrl!.isEmpty)
                                ? Text(
                                    '${user.nombre[0]}${user.apellido[0]}',
                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isLoading ? null : _seleccionarYSubirImagen,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, size: 20, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('${user.nombre} ${user.apellido}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user.email, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _nombreController, label: 'Nombre', icon: Icons.person_outline, enabled: _editMode, validator: (value) => value!.isEmpty ? 'Campo requerido' : null),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _apellidoController, label: 'Apellido', icon: Icons.person_outline, enabled: _editMode, validator: (value) => value!.isEmpty ? 'Campo requerido' : null),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _emailController, label: 'Correo electrónico', icon: Icons.email_outlined, enabled: _editMode, validator: (value) => !value!.contains('@') ? 'Correo inválido' : null, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _telefonoController, label: 'Teléfono', icon: Icons.phone_outlined, enabled: _editMode, keyboardType: TextInputType.phone),
                    if (_editMode) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('GUARDAR CAMBIOS'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: _isLoading ? null : () => _guardarCambios(user),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Text('Opciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    const SizedBox(height: 16),
                    _buildOptionTile(icon: Icons.logout, title: 'Cerrar sesión', onTap: () => _mostrarDialogoCerrarSesion(context), textColor: Colors.red, iconColor: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar tu sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthController>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CERRAR SESIÓN'),
          ),
        ],
      ),
    );
  }
}