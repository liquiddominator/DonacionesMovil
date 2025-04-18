import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  final Widget nextScreen;

  const SplashPage({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _progressValue = 0.0;
  
  final List<String> _featurePoints = [
    "Transparencia en tiempo real",
    "Seguimiento de donaciones",
    "Información verificada",
    "Reportes detallados",
    "Conexión directa con donantes"
  ];
  
  late List<bool> _pointsVisible;
  Timer? _progressTimer;
  List<Timer> _pointTimers = [];

  @override
  void initState() {
    super.initState();
    
    _pointsVisible = List.generate(_featurePoints.length, (_) => false);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _animationController.forward();
    
    // Animación de la barra de progreso
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_progressValue < 1.0) {
        if (mounted) {
          setState(() {
            _progressValue += 0.02;
          });
        }
      } else {
        timer.cancel();
      }
    });
    
    // Mostrar los puntos de descripción secuencialmente
    for (int i = 0; i < _featurePoints.length; i++) {
      final timer = Timer(Duration(milliseconds: 500 + (i * 300)), () {
        if (mounted) {
          setState(() {
            _pointsVisible[i] = true;
          });
        }
      });
      _pointTimers.add(timer);
    }
    
    // Temporizador para navegar a la siguiente pantalla
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(opacity: fadeIn, child: child);
            },
            transitionDuration: Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancelar todos los timers y animaciones
    _progressTimer?.cancel();
    for (var timer in _pointTimers) {
      timer.cancel();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colores naranja pastel
    const Color primaryColor = Color(0xFFFFB74D); // Naranja claro
    const Color secondaryColor = Color(0xFFFFCCBC); // Naranja pastel más claro
    const Color backgroundColor = Color(0xFFFFF3E0); // Fondo naranja muy suave
    const Color accentColor = Color(0xFFFF8A65); // Naranja más intenso para acentos

    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Logo con animaciones
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset('assets/logo.png'),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Título de la aplicación
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    'Donaciones Beni',
                    style: TextStyle(
                      color: Colors.deepOrange.shade700,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Texto descriptivo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    );
                  },
                  child: Text(
                    'Sistema de transparencia en donaciones',
                    style: TextStyle(
                      color: Colors.deepOrange.shade700,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Puntos de descripción
                Container(
                  width: screenSize.width * 0.8,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(_featurePoints.length, (index) {
                      return AnimatedOpacity(
                        opacity: _pointsVisible[index] ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: accentColor,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                _featurePoints[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.deepOrange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Indicador de carga más elaborado
                Column(
                  children: [
                    // Barra de progreso lineal
                    Container(
                      width: screenSize.width * 0.7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          backgroundColor: secondaryColor,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Texto de carga con animación
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Cargando ${(_progressValue * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.deepOrange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // Texto adicional animado
                    SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(seconds: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'Preparando todo para ti...',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                // Nota de versión en la parte inferior
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: AnimatedOpacity(
                        opacity: _progressValue > 0.7 ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: Colors.deepOrange.shade700.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
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