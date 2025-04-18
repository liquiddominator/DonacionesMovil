import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/models/usuario.dart';
import 'package:donaciones_movil/views/campanias/detalle_campania_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CampaniaListPage extends StatefulWidget {
  const CampaniaListPage({Key? key}) : super(key: key);

  @override
  _CampaniasActivasScreenState createState() => _CampaniasActivasScreenState();
}

class _CampaniasActivasScreenState extends State<CampaniaListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final campaniaController = Provider.of<CampaniaController>(context, listen: false);
      final userController = Provider.of<UserController>(context, listen: false);

      await campaniaController.loadCampaniasActivas();
      await userController.loadUsuarios();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Campañas Activas')),
    body: Consumer2<CampaniaController, UserController>(
      builder: (context, campaniaController, userController, _) {
        if (campaniaController.isLoading || userController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (campaniaController.campanias == null || campaniaController.campanias!.isEmpty) {
          return const Center(child: Text('No hay campañas activas.'));
        }

        return ListView.builder(
          itemCount: campaniaController.campanias!.length,
          itemBuilder: (context, index) {
            final campania = campaniaController.campanias![index];

            final creador = userController.usuarios?.firstWhere(
              (u) => u.usuarioId == campania.usuarioIdcreador,
              orElse: () => Usuario(
                usuarioId: 0,
                email: 'Desconocido',
                contrasena: '',
                nombre: '',
                apellido: '',
              ),
            );

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(campania.titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campania.descripcion),
                    const SizedBox(height: 4),
                    Text('Inicio: ${DateFormat.yMMMd().format(campania.fechaInicio)}'),
                    if (campania.fechaFin != null)
                    Text('Fin: ${DateFormat.yMMMd().format(campania.fechaFin!)}'),
                    Text('Meta: \$${campania.metaRecaudacion.toStringAsFixed(2)}'),
                    Text('Recaudado: \$${(campania.montoRecaudado ?? 0).toStringAsFixed(2)}'),
                    Text(
                      creador != null
                      ? 'Creado por: ${creador.nombre} ${creador.apellido} (${creador.email})'
                      : 'Creado por: Desconocido',
                    ),
                  ],
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleCampaniaPage(campania: campania),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    ),
  );
}
}