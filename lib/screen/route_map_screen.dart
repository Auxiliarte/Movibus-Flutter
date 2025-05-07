import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_model.dart';

class RouteMapScreen extends StatelessWidget {
  final RouteModel ruta;

  const RouteMapScreen({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    final firstLocation = ruta.locations.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(ruta.nombre),
        backgroundColor: Colors.deepPurple,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(firstLocation.latitude, firstLocation.longitude),
          zoom: 13,
        ),
        markers: {
          for (var loc in ruta.locations)
            Marker(
              markerId: MarkerId("${loc.order}-${loc.name}"),
              position: LatLng(loc.latitude, loc.longitude),
              infoWindow: InfoWindow(title: loc.name),
            ),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId("ruta"),
            color: Colors.deepPurple,
            width: 5,
            points: ruta.locations
                .map((loc) => LatLng(loc.latitude, loc.longitude))
                .toList(),
          ),
        },
      ),
    );
  }
}
