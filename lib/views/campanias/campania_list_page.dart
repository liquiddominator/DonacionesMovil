import 'package:donaciones_movil/controllers/campania_controller.dart';
import 'package:donaciones_movil/controllers/user_controller.dart';
import 'package:donaciones_movil/utils/currency_format.dart';
import 'package:donaciones_movil/widgets/campania/campania_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CampaniaListPage extends StatefulWidget {
  const CampaniaListPage({Key? key}) : super(key: key);

  @override
  _CampaniasActivasScreenState createState() => _CampaniasActivasScreenState();
}

class _CampaniasActivasScreenState extends State<CampaniaListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'Todas';
  bool _ordenarPorMontoMayor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final campaniaController = Provider.of<CampaniaController>(context, listen: false);
      final userController = Provider.of<UserController>(context, listen: false);

      await campaniaController.loadCampaniasActivas();
      await userController.loadUsuarios();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFFF58C5B),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6F0),
        body: Consumer2<CampaniaController, UserController>(
          builder: (context, campaniaController, userController, _) {
            if (campaniaController.isLoading || userController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (campaniaController.campanias == null || campaniaController.campanias!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No hay campañas activas', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              );
            }

            final usuariosMap = {
              for (var usuario in userController.usuarios ?? [])
                usuario.usuarioId: usuario
            };

            final hoy = DateTime.now();
            List filtered = campaniaController.campanias!
                .where((c) {
                  final tituloMatch = c.titulo.toLowerCase().contains(_searchQuery);
                  if (_activeFilter == 'Por finalizar') {
                    final fechaFin = c.fechaFin;
                    return tituloMatch &&
                        fechaFin != null &&
                        fechaFin.difference(hoy).inDays <= 7 &&
                        fechaFin.isAfter(hoy);
                  }
                  return tituloMatch;
                })
                .toList();

            // Ordenar por monto recaudado si está activo
            if (_ordenarPorMontoMayor) {
              filtered.sort((a, b) =>
                  (b.montoRecaudado ?? 0).compareTo(a.montoRecaudado ?? 0));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado superior
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF58C5B),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Campañas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar campañas...',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),

                // Filtros
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todas'),
                        _buildFilterChip('Por finalizar'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtered.length} Campañas',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _ordenarPorMontoMayor ? Icons.filter_alt : Icons.filter_list,
                          color: const Color(0xFF787878),
                        ),
                        tooltip: 'Ordenar por monto recaudado',
                        onPressed: () {
                          setState(() {
                            _ordenarPorMontoMayor = !_ordenarPorMontoMayor;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final campania = filtered[index];
                      final creador = usuariosMap[campania.usuarioIdcreador];
                      return CampaniaCard(
                        campania: campania,
                        creador: creador,
                        currencyFormat: currencyFormatter,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() {
          _activeFilter = label;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF58C5B) : const Color(0xFFFFE5D4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF2F2F2F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}