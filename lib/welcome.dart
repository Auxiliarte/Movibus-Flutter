import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moventra/themes/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  double _imageTopPosition = 0;
  bool _animationCompleted = false;
  int _currentSlide = 0;

  final List<String> _imagePaths = [
    'assets/minecraft-dynamic-gradient.png',
    'assets/Frame1.png',
    'assets/Frame.png',
  ];

  final List<String> _titles = [
    '¡Bienvenido a Moventra!',
    '¡Viaja mejor con Moventra!',
    'Moventra - Tu viaje, tu ruta.',
  ];

  final List<String> _subtitles = [
    'Tu compañero ideal para moverte por la ciudad.',
    'Consulta rutas, horarios y ubicaciones en tiempo real para un viaje más fácil y rápido.',
    'Encuentra el camión que necesitas, revisa horarios y sigue su ubicación.',
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Reducir tiempo de espera
    setState(() {
      _imageTopPosition = -MediaQuery.of(context).size.height;
    });

    await Future.delayed(
      const Duration(milliseconds: 880),
    ); // Reducir espera adicional
    setState(() {
      _animationCompleted = true;
    });
  }

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'https://app.moventra.com.mx/api';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.secondaryHeaderColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Cortina animada
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: _imageTopPosition,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: AppColors.darkBodyBackground,
                child: Center(
                  child: Image.asset(
                    'assets/logoMoventra.png',
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
            ),

            // Mostrar contenido solo después de que la animación haya terminado
            if (_animationCompleted)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity:
                    1.0, // Al finalizar la animación, la opacidad será 1 (totalmente visible)
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Carrusel de imágenes
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 180,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          autoPlayInterval: const Duration(seconds: 4),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentSlide = index;
                            });
                          },
                        ),
                        items:
                            _imagePaths.map((imagePath) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(0),
                                    child: Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 12),

                      // Indicadores del carrusel
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            _imagePaths.asMap().entries.map((entry) {
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentSlide == entry.key
                                          ? const Color(0xFF2E0E6B)
                                          : Colors.grey.shade400,
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Títulos y subtítulos sincronizados
                      Center(
                        child: Text(
                          _titles[_currentSlide],
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                            // Color para el modo claro
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: Text(
                          _subtitles[_currentSlide],
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botón principal de login
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA13CF2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón secundario de registro
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: const BorderSide(color: Color(0xFFA13CF2)),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Registrate',
                              style: TextStyle(color: Color(0xFFA13CF2)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                              endIndent: 10,
                            ),
                          ),
                          Text(
                            "o continua con",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                              indent: 10,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Redes sociales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Apple
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.apple,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),

                          // Facebook
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1877F2),
                            ),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/Icon/icons-facebook.png',
                                color: Colors.white,
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {},
                            ),
                          ),

                          // Google
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE0E0E0),
                            ),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/Icon/icons-google.png',
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {},
                            ),
                          ),

                          // X (Twitter)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1DA1F2),
                            ),
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.twitter,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
