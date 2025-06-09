import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:donaciones_movil/widgets/navegacion/main_navigation_page.dart';
import 'package:donaciones_movil/widgets/perfil/dialogo_cerrar_sesion.dart';
import 'package:donaciones_movil/widgets/perfil/personal_info_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
            const SnackBar(
              content: Text('Información actualizada con éxito'),
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
          const SnackBar(content: Text('Imagen actualizada'), backgroundColor: Colors.green),
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

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Cambiar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarYSubirImagen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_red_eye),
                title: const Text('Ver foto'),
                onTap: () {
                  Navigator.pop(context);
                  _verImagenCompleta();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _verImagenCompleta() {
    final user = Provider.of<AuthController>(context, listen: false).currentUser!;
    if (user.imagenUrl == null || user.imagenUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imagen para mostrar')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: InteractiveViewer(
          child: Image.network(user.imagenUrl!),
        ),
      ),
    );
  }

  Widget _donacionItem(IconData icon, String texto, Color colorIcono) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: colorIcono,
      child: Icon(icon, color: Colors.white),
    ),
    title: Text(texto),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {}, // Aquí puedes añadir navegación luego
  );
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

  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: const Color(0xFFF58C5B),
      statusBarIconBrightness: Brightness.light,
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER estilo BandejaEntrada pero sin back button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF58C5B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Stack(
  children: [
    Positioned(
      top: 0,
      right: 0,
      child: IconButton(
        icon: Icon(_editMode ? Icons.close : Icons.edit, color: Colors.white),
        tooltip: _editMode ? 'Cancelar edición' : 'Editar perfil',
        onPressed: () => setState(() => _editMode = !_editMode),
      ),
    ),
    Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isLoading ? null : _mostrarOpcionesImagen,
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white,
              backgroundImage: user.imagenUrl != null && user.imagenUrl!.isNotEmpty
                  ? NetworkImage(user.imagenUrl!)
                  : null,
              child: (user.imagenUrl == null || user.imagenUrl!.isEmpty)
                  ? Text(
                      '${user.nombre[0]}${user.apellido[0]}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF58C5B),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${user.nombre} ${user.apellido}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              user.email,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

            ),


            // CONTENIDO
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PersonalInfoCard(
                    user: user,
                    editMode: _editMode,
                    isLoading: _isLoading,
                    onSave: () => _guardarCambios(user),
                    nombreController: _nombreController,
                    apellidoController: _apellidoController,
                    emailController: _emailController,
                    telefonoController: _telefonoController,
                    formKey: _formKey,
                  ),
                  const SizedBox(height: 30),
                  Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Encabezado
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFE0CB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 8),
            const Text(
              'Mis Donaciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
      // Items
      Column(
        children: [
          ListTile(
  leading: const CircleAvatar(
    backgroundColor: Color(0xFFFFB72B),
    child: Icon(Icons.savings, color: Colors.white),
  ),
  title: const Text('Historial de Donaciones'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    MainNavigationPage.of(context)?.changeTab(2);
  },
),
        ],
      ),
    ],
  ),
),
const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE0CB),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: const [
                              Icon(Icons.settings, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                'Configuración',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF58C5B),
                              child: const Icon(Icons.door_back_door_outlined, color: Colors.white),
                            ),
                            title: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => mostrarDialogoCerrarSesion(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}