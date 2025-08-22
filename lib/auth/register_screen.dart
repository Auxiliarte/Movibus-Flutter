import 'package:flutter/material.dart';
import 'package:moventra/widgets/Auth/register/step1_content.dart';
import 'package:moventra/widgets/Auth/register/step2_content.dart';
import 'package:moventra/widgets/Auth/register/step3_content.dart';
import '../widgets/loading_screen.dart';
import '../widgets/custom_text_form_field.dart';
import '../services/auth_service.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _errorMessage;

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

  void _continuar() async {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      // Validar que todos los campos estén completos antes de enviar
      if (_nombreController.text.isEmpty ||
          _apellidoController.text.isEmpty ||
          _correoController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _passwordConfirmationController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Por favor completa todos los campos';
        });
        return;
      }

      if (_passwordController.text != _passwordConfirmationController.text) {
        setState(() {
          _errorMessage = 'Las contraseñas no coinciden';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await _authService.register(
          name: _nombreController.text,
          lastName: _apellidoController.text,
          email: _correoController.text,
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmationController.text,
        );

        if (mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Usuario registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );

          // Pequeño delay para que el usuario vea el mensaje
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            // Redirigir al home con la sesión ya iniciada
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
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
                              Expanded(
                                child: Center(
                                  child: Text(
                                    _stepTitles[_currentStep],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // Espacio para mantener el balance visual
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

                        // Mensaje de error
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                        fontFamily: 'Quicksand',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                backgroundColor: WidgetStateProperty.all(
                                  const Color(0xFFA13CF2),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                shape: WidgetStateProperty.all<
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
        return Step2Content(
          passwordController: _passwordController,
          passwordConfirmationController: _passwordConfirmationController,
        );
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
