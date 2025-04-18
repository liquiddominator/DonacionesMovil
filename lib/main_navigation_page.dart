import 'package:donaciones_movil/views/campanias/campania_list_page.dart';
import 'package:donaciones_movil/views/dashboard/dashboard_page.dart';
import 'package:donaciones_movil/views/donaciones/historial_donaciones_page.dart';
import 'package:donaciones_movil/views/mensajes/bandeja_entrada_page.dart';
import 'package:donaciones_movil/views/perfil/perfil_usuario_page.dart';
import 'package:flutter/material.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  
  // Lista de pantallas para navegar
  final List<Widget> _screens = [
    const DashboardPage(),
    const CampaniaListPage(), // CampaniaPage
    const HistorialDonacionesPage(), // DonacionesPage
    const BandejaEntradaPage(), 
    const PerfilUsuarioPage(), // PerfilPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Campañas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism_outlined),
              activeIcon: Icon(Icons.volunteer_activism),
              label: 'Donaciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message),
              label: 'Mensajeria',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          elevation: 0,
        ),
      ),
    );
  }
}