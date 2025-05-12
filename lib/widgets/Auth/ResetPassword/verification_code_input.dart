import 'package:flutter/material.dart';

class VerificationCodeInput extends StatefulWidget {
  final List<TextEditingController> codeControllers;
  final List<FocusNode> focusNodes;
  final String? errorMessage;

  const VerificationCodeInput({
    Key? key,
    required this.codeControllers,
    required this.focusNodes,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  bool showResendMessage = false;

  void _handleResend() {
    setState(() {
      showResendMessage = true;
    });

    // Ocultar mensaje después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showResendMessage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontFamily: 'Quicksand',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: 60,
                height: 60,
                child: TextField(
                  controller: widget.codeControllers[index],
                  focusNode: widget.focusNodes[index],
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
                      ).requestFocus(widget.focusNodes[index + 1]);
                    }
                    if (value.isEmpty && index > 0) {
                      FocusScope.of(
                        context,
                      ).requestFocus(widget.focusNodes[index - 1]);
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

        // Mensaje mostrado durante 5 segundos
        if (showResendMessage)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'En reenvío el código de verificación a tu correo',
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),

        TextButton(
          onPressed: showResendMessage ? null : _handleResend,
          child: Text(
            'Reenviar',
            style: TextStyle(
              color: showResendMessage ? Colors.grey : const Color(0xFFA13CF2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
