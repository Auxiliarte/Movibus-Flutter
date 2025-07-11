import 'package:flutter/material.dart';
import 'package:moventra/widgets/custom_text_form_field.dart';

class Step1Content extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController correoController;
  final GlobalKey<FormState> formKey;
  final bool aceptaPromos;
  final ValueChanged<bool?> onChanged;

  const Step1Content({
    Key? key,
    required this.nombreController,
    required this.apellidoController,
    required this.correoController,
    required this.formKey,
    required this.aceptaPromos,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: nombreController,
                  label: 'Nombre',
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextFormField(
                  controller: apellidoController,
                  label: 'Apellido',
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          CustomTextFormField(
            controller: correoController,
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
                    value: aceptaPromos,
                    onChanged: onChanged,
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
  }
}
