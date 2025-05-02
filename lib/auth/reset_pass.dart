import 'package:flutter/material.dart';
import '../widgets/LoadingScreen.dart';
import '../widgets/custom_text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  int _currentStep = 0;

  bool _isLoading = true;
  bool codigoReenviado = false;
  String? _codigoError;

  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  final TextEditingController _correoController = TextEditingController();
  final stepTitles = [
    'Restablece tu contraseña',
    'Introduzca el código',
    'Establece tu nueva contraseña',
  ];

  final stepSubtitles = [
    '',
    'Introduzca el código de 4 dígitos que acabamos de enviarle a su correo electrónico *******@gmail.com',
    'Por favor, ingresa una contraseña que cumpla con los siguientes requisitos:',
  ];

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

    if (_currentStep == 1) {
      String codigo = _codeControllers.map((c) => c.text).join();
      if (codigo.length != 4 || !RegExp(r'^\d{4}$').hasMatch(codigo)) {
        setState(() {
          _codigoError = 'El código debe contener 4 dígitos numéricos';
        });
        return;
      } else {
        setState(() {
          _codigoError = null;
        });
      }
    }

    if (_currentStep == 2) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          // (context, '/success');
        });
      });

      return;
    }

    setState(() => _currentStep += 1);
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: _correoController,
                label: 'Introduce tu Correo ',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'El correo es requerido'
                            : null,
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Recibirás un código de autenticación para poder cambiar tu contraseña.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontFamily: 'Quicksand',
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ),
            ],
          ),
        );

      //Codigo de verificación
      case 1:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),

              // Mensaje de error si existe
              if (_codigoError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _codigoError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: 'Quicksand',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Campos de verificación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index + 1]);
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_focusNodes[index - 1]);
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 180, 180, 180),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFA13CF2),
                              width: 2,
                            ),
                          ),
                          hintText: '•',
                          hintStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  setState(() {
                    codigoReenviado = true;
                  });
                },
                child: const Text(
                  'Reenviar',
                  style: TextStyle(
                    color: Color(0xFFA13CF2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (codigoReenviado)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Se envió código de verificación.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );

      //Establecer nueva contraseña
      case 2:
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
                labelText: 'Contraseña',
                labelStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Color.fromARGB(255, 100, 100, 100),
                ),
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

      default:
        return const SizedBox.shrink();
    }
  }

  //biuld con sup / inf.
  @override
  Widget build(BuildContext context) {
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

                        // Títulos y subtítulos dinámicos por paso
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Align(
                            alignment:
                                _currentStep == 1
                                    ? Alignment.center
                                    : Alignment.centerLeft,
                            child: Text(
                              stepTitles[_currentStep],
                              textAlign:
                                  _currentStep == 1
                                      ? TextAlign.center
                                      : TextAlign.left,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment:
                                _currentStep == 1
                                    ? Alignment.center
                                    : Alignment.centerLeft,
                            child: Text(
                              stepSubtitles[_currentStep],
                              textAlign:
                                  _currentStep == 1
                                      ? TextAlign.center
                                      : TextAlign.left,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: _currentStep == 0 ? 0 : 16,
                              bottom: _currentStep == 0 ? 0 : 16,
                            ),
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
