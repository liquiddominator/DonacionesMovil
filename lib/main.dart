import 'package:donaciones_movil/controllers/asignacion_controller.dart';
import 'package:donaciones_movil/controllers/auth/auth_controller.dart';
import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/comentario_controller.dart';
import 'package:donaciones_movil/controllers/detalle_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_asignacion_controller.dart';
import 'package:donaciones_movil/controllers/donacion_controller.dart';
import 'package:donaciones_movil/controllers/estado_controller.dart';
import 'package:donaciones_movil/controllers/mensaje_controller.dart';
import 'package:donaciones_movil/controllers/respuesta_mensaje_controller.dart';
import 'package:donaciones_movil/controllers/rol_controller.dart';
import 'package:donaciones_movil/controllers/saldos_donacion_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/controllers/usuario_rol_controller.dart';
import 'package:donaciones_movil/views/auth/login_page.dart';
import 'package:donaciones_movil/views/auth/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('es_BO', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => CampaniaController()),
        ChangeNotifierProvider(create: (_) => SaldosDonacionController()),
        ChangeNotifierProvider(create: (_) => RespuestaMensajeController()),
        ChangeNotifierProvider(create: (_) => MensajeController()),
        ChangeNotifierProvider(create: (_) => EstadoController()),
        ChangeNotifierProvider(create: (_) => DonacionController()),
        ChangeNotifierProvider(create: (_) => DonacionAsignacionController()),
        ChangeNotifierProvider(create: (_) => DetalleAsignacionController()),
        ChangeNotifierProvider(create: (_) => AsignacionController()),
        ChangeNotifierProvider(create: (_) => RolController()),
        ChangeNotifierProvider(create: (_) => UsuarioRolController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ComentarioController()),
      ],
      child: MaterialApp(
        title: 'Donaciones App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SplashPage(nextScreen: LoginPage()),
      ),
    );
  }
}