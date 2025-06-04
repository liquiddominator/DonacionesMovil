import 'package:donaciones_movil/utils/app_colors.dart';
import 'package:donaciones_movil/views/campanias/campania_list_page.dart';
import 'package:donaciones_movil/views/dashboard/dashboard_page.dart';
import 'package:donaciones_movil/views/donaciones/historial_donaciones_page.dart';
import 'package:donaciones_movil/views/mensajes/bandeja_entrada_page.dart';
import 'package:donaciones_movil/views/perfil/perfil_usuario_page.dart';
import 'package:flutter/material.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  static _MainNavigationScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainNavigationScreenState>();

  @override
  State<MainNavigationPage> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Color?>> _colorAnimations;

  final List<Widget> _screens = const [
    DashboardPage(),
    CampaniaListPage(),
    HistorialDonacionesPage(),
    BandejaEntradaPage(),
    PerfilUsuarioPage(),
  ];

  final List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.campaign_outlined,
    Icons.volunteer_activism_outlined,
    Icons.message_outlined,
    Icons.person_outline,
  ];

  final List<IconData> _activeIcons = [
    Icons.dashboard,
    Icons.campaign,
    Icons.volunteer_activism,
    Icons.message,
    Icons.person,
  ];

  final List<String> _labels = [
    'Dashboard',
    'Campañas',
    'Donaciones',
    'Mensajería',
    'Perfil',
  ];

  void changeTab(int index) {
    _animationControllers[_selectedIndex].reverse();
    _selectedIndex = index;
    _animationControllers[_selectedIndex].forward();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 1.0,
              end: 1.2,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            )))
        .toList();

    _colorAnimations = _animationControllers
        .map((controller) => ColorTween(
              begin: AppColors.secondary,
              end: AppColors.primary,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Animar el primer elemento como seleccionado
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      // Reversa la animación del ítem anterior
      _animationControllers[_selectedIndex].reverse();
      
      setState(() {
        _selectedIndex = index;
      });
      
      // Anima el nuevo ítem seleccionado
      _animationControllers[index].forward();
    }
  }

  Widget _buildNavItem(int index) {
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimations[index],
                _colorAnimations[index],
              ]),
              builder: (context, child) {
                final isSelected = _selectedIndex == index;
                return Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSelected ? _activeIcons[index] : _icons[index],
                      color: _colorAnimations[index].value,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
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
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            height: 70,
            child: Row(
              children: List.generate(5, (index) => _buildNavItem(index)),
            ),
          ),
        ),
      ),
    );
  }
}