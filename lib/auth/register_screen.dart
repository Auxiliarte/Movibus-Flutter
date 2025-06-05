import 'package:flutter/material.dart';
import 'package:movibus/widgets/Auth/register/Step1Content.dart';
import 'package:movibus/widgets/Auth/register/Step2Content.dart';
import 'package:movibus/widgets/Auth/register/Step3Content.dart';
import '../widgets/LoadingScreen.dart';
import '../widgets/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  bool _isLoading = true;
  bool _aceptaNotificaciones = false;
  bool _aceptaPromos = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  final stepTitles = [
    'Comencemos',
    'Establece tu contraseña',
    'Activar notificaciones',
  ];

  final stepSubtitles = [
    'Ingresa los siguientes datos para crear tu cuenta',
    'Por favor, ingresa una contraseña que cumpla con los siguientes requisitos:',
    'Para recibir actualizaciones nuestras.',
  ];

  final _stepTitles = ['Paso 1', 'Paso 2', 'Paso 3'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _continuar() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/Welcome');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentStep + 1) / 3;

    final quicksandTextTheme = Theme.of(
      context,
    ).textTheme.apply(fontFamily: 'Quicksand');

    return Theme(
      data: Theme.of(context).copyWith(textTheme: quicksandTextTheme),
      child: Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        body:
            _isLoading
                ? const CustomLoadingWidget()
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Encabezado con flecha y título
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  if (_currentStep == 0) {
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      _currentStep -= 1;
                                    });
                                  }
                                },
                              ),
                              Text(
                                _stepTitles[_currentStep],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/settings');
                                },
                              ),
                            ],
                          ),
                        ),

                        // Barra de progreso
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFFA13CF2),
                          ),
                        ),

                        // Títulos
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              stepTitles[_currentStep],
                              style: Theme.of(
                                context,
                              ).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        ),

                        // Subtítulo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              stepSubtitles[_currentStep],
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Contenido dinámico
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _buildStepContent(),
                          ),
                        ),

                        // Botón continuar/finalizar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFA13CF2),
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                                shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder
                                >(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              onPressed: _continuar,
                              child: Text(
                                _currentStep < 2 ? 'Continuar' : 'Finalizar',
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Step1Content(
          nombreController: _nombreController,
          apellidoController: _apellidoController,
          correoController: _correoController,
          formKey: _formKey,
          aceptaPromos: _aceptaPromos,
          onChanged: (value) {
            setState(() {
              _aceptaPromos = value ?? false;
            });
          },
        );
      case 1:
        return const Step2Content();
      case 2:
        return Step3Content(
          aceptaNotificaciones: _aceptaNotificaciones,
          aceptaPromos: _aceptaPromos,
          onChangedNotificaciones: (value) {
            setState(() {
              _aceptaNotificaciones = value ?? false;
            });
          },
          onChangedPromos: (value) {
            setState(() {
              _aceptaPromos = value ?? false;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
