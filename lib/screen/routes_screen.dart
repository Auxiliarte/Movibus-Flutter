import 'dart:io';
import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import 'route_map_screen.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://192.168.1.221:8000/api';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas"),
        backgroundColor: Colors.deepPurple,
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(ruta.nombre),
                  subtitle: Text(
                    "${ruta.locations.length} paradas"
                    "${ruta.busNombre != null ? " - ${ruta.busNombre}" : ""}",
                  ),
                  leading: const Icon(Icons.route, color: Colors.deepPurple),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RouteMapScreen(ruta: ruta),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
