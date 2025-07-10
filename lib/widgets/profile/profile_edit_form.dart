import 'package:flutter/material.dart';

class EditPersonalInfoForm extends StatefulWidget {
  const EditPersonalInfoForm({super.key});

  @override
  State<EditPersonalInfoForm> createState() => _EditPersonalInfoFormState();
}

class _EditPersonalInfoFormState extends State<EditPersonalInfoForm> {
  String selectedGender = "Masculino";
  String selectedState = "San Luis Potosí";

  final TextEditingController nameController = TextEditingController(
    text: "José Arturo",
  );
  final TextEditingController lastNameController = TextEditingController(
    text: "Sanchez Garduño",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "+524446241938",
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/Avatars.png'),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Color(0xFFA13CF2),
                    child: Icon(Icons.edit, size: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField("Nombre", nameController),
            const SizedBox(height: 20),
            _buildTextField("Apellidos", lastNameController),
            const SizedBox(height: 20),
            _buildDropdown("Sexo", selectedGender, ["Masculino", "Femenino"], (
              value,
            ) {
              setState(() => selectedGender = value);
            }),
            const SizedBox(height: 20),
            _buildDropdown(
              "Estado",
              selectedState,
              ["San Luis Potosí", "CDMX", "Jalisco"],
              (value) {
                setState(() => selectedState = value);
              },
            ),
            const SizedBox(height: 20),
            _buildTextField("Número de teléfono", phoneController),
            const SizedBox(height: 80),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA13CF2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Guardar",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    const fieldTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,

      fontFamily: 'Quicksand',
    );

    return TextField(
      controller: controller,
      style: fieldTextStyle,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: fieldTextStyle,
        hintStyle: fieldTextStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items:
          options
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
