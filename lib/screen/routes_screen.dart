import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import 'route_map_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  int _currentIndex = 1;

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/routesHistory');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'https://app.moventra.com.mx/api';
    } else {
      return 'https://app.moventra.com.mx/api';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas"),
        backgroundColor: theme.secondaryHeaderColor,
      ),
      body: FutureBuilder<List<RouteModel>>(
        future: RouteService.fetchRoutes(getBackendUrl()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar rutas"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay rutas disponibles"));
          }

          final rutas = snapshot.data!;
          return ListView.builder(
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              final ruta = rutas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RouteMapScreen(ruta: ruta),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.route, color: Colors.deepPurple),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ruta.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${ruta.locations.length} paradas"
                              "${ruta.busNombre != null ? " - ${ruta.busNombre}" : ""}",
                              style: const TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
