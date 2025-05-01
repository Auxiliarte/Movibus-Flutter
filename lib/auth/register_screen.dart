import 'package:flutter/material.dart';
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
  bool _aceptaPromos = false;

  final List<String> _stepTitles = ['Paso 1', 'Paso 2', 'Paso 3'];

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Formulario enviado')));
    }
  }

  void _cancelar() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _nombreController,
                      label: 'Nombre',
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _apellidoController,
                      label: 'Apellido',
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              CustomTextFormField(
                controller: _correoController,
                label: 'Correo Electrónico',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'El correo es requerido'
                            : null,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Suscribirse para recibir correos electrónicos promocionales',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _aceptaPromos,
                        onChanged: (value) {
                          setState(() {
                            _aceptaPromos = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFFA13CF2),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '• Mínimo 8 caracteres\n'
              '• Al menos una letra mayúscula\n'
              '• Al menos una letra minúscula\n'
              '• Al menos un número\n'
              '• Al menos un carácter especial (@, #, \$, etc.)',
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                fontFamily: 'Quicksand',
                color: Color(0xFF8C8C8C),
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 180, 180, 180),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 180, 180, 180),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFA13CF2), width: 2),
                ),
              ),
            ),
          ],
        );

      //notificaciones
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/Illustration.png',
                width: 350,
                height: 350,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),

            // Recibir notificaciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recibir notificaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _aceptaNotificaciones,
                    onChanged: (value) {
                      setState(() {
                        _aceptaNotificaciones = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFA13CF2),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),

            const Divider(color: Color(0xFFDDDDDD), thickness: 1, height: 40),

            // Recibir promociones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recibir promociones',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _aceptaPromos,
                    onChanged: (value) {
                      setState(() {
                        _aceptaPromos = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFFA13CF2),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  //biuld con sup / inf.
  @override
  Widget build(BuildContext context) {
    double progress = (_currentStep + 1) / 3;

    final quicksandTextTheme = Theme.of(
      context,
    ).textTheme.apply(fontFamily: 'Quicksand');

    return Theme(
      data: Theme.of(context).copyWith(textTheme: quicksandTextTheme),
      child: Scaffold(
        body:
            _isLoading
                ? const CustomLoadingWidget()
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Configuración'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFFA13CF2),
                          ),
                        ),

                        // Títulos y subtítulos dinámicos por paso
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              stepSubtitles[_currentStep],
                              style: const TextStyle(
                                fontSize: 17,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _buildStepContent(),
                          ),
                        ),
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
                                style: TextStyle(
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
}
