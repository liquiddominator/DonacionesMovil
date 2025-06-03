import 'package:donaciones_movil/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  final Widget nextScreen;
  const SplashPage({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  double _progressValue = 0.0;
  Timer? _timer;

  final List<String> _loadingTexts = [
    'Cargando datos...',
    'Sincronizando campañas...',
    'Casi listo...'
  ];
  String _currentText = 'Cargando datos...';

  late final AnimationController _logoController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  late final List<AnimationController> _featureControllers;
  late final List<Animation<Offset>> _featureAnimations;
  late final List<Animation<double>> _featureOpacities;

  @override
  void initState() {
    super.initState();

    // Logo animation mejorada
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOutQuad),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutExpo),
    );

    _logoController.forward();

    // Features animation
    _featureControllers = List.generate(3, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _featureAnimations = _featureControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    _featureOpacities = _featureControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeIn),
      );
    }).toList();

    Future.delayed(const Duration(milliseconds: 500), () => _featureControllers[0].forward());
    Future.delayed(const Duration(milliseconds: 900), () => _featureControllers[1].forward());
    Future.delayed(const Duration(milliseconds: 1300), () => _featureControllers[2].forward());

    // Progress bar timer
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_progressValue < 1.0) {
        setState(() {
          _progressValue += 0.02;
          int index = (_progressValue * _loadingTexts.length).clamp(0, 2).toInt();
          _currentText = _loadingTexts[index];
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    for (final c in _featureControllers) {
      c.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFFFE5D0),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo con animación más elaborada
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  'TraceGive',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Transparencia en cada donación',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 45),

                Container(
                  width: screenWidth * 0.6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.cardBackground,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: (screenWidth * 0.6) * _progressValue,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.success],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),
                AnimatedFeatureBlock(
                  title: 'Transparencia Total',
                  description: 'Ve exactamente cómo se utiliza cada donación\ncon reportes detallados y comprobantes',
                  animation: _featureAnimations[0],
                  opacity: _featureOpacities[0],
                ),
                const SizedBox(height: 16),
                AnimatedFeatureBlock(
                  title: 'Seguimiento en Tiempo Real',
                  description: 'Rastrea el progreso de las campañas y el impacto\nde tus contribuciones',
                  animation: _featureAnimations[1],
                  opacity: _featureOpacities[1],
                ),
                const SizedBox(height: 16),
                AnimatedFeatureBlock(
                  title: 'Donaciones Seguras',
                  description: 'Plataforma confiable que garantiza que tu ayuda\nllegue a quien más lo necesita',
                  animation: _featureAnimations[2],
                  opacity: _featureOpacities[2],
                ),
                const SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: const [
                    _PillLabel(text: 'Transparente'),
                    _PillLabel(text: 'Seguro'),
                    _PillLabel(text: 'Confiable'),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedFeatureBlock extends StatelessWidget {
  final String title;
  final String description;
  final Animation<Offset> animation;
  final Animation<double> opacity;

  const AnimatedFeatureBlock({
    super.key,
    required this.title,
    required this.description,
    required this.animation,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  final String text;
  const _PillLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 221, 190),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}