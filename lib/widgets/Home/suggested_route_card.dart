import 'package:flutter/material.dart';
import 'package:moventra/screen/route_bus_screen.dart';
import 'package:moventra/themes/app_colors.dart';

class SuggestedRouteCard extends StatelessWidget {
  final String ruta;
  final String salida;
  final String tiempo;
  final String horaLlegada;

  const SuggestedRouteCard({
    Key? key,
    required this.ruta,
    required this.salida,
    required this.tiempo,
    required this.horaLlegada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromARGB(241, 255, 255, 255)),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.directions_bus_outlined,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ruta,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'quicksand',
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                  Text(
                    salida,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontFamily: 'quicksand',
                    ),
                  ),
                  const Divider(color: Color.fromARGB(255, 204, 203, 203)),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tiempo,
                        style: TextStyle(
                          color: AppColors.darkInputFocus,
                          fontWeight: FontWeight.w500,
                          fontFamily: "quicksand",
                        ),
                      ),
                      Text(
                        "Llegada a las: $horaLlegada",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: "quicksand",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
