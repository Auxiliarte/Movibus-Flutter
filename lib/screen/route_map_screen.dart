import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moventra/widgets/routes/custom_draggable_sheet.dart';
import 'package:moventra/widgets/routes/rating_sheet.dart';
import '../models/route_model.dart';

class RouteMapScreen extends StatefulWidget {
  final RouteModel ruta;

  const RouteMapScreen({super.key, required this.ruta});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final List<Map<String, String>> busStops = [
    {
      'title': 'Comenzar',
      'description': 'Avenida industrias, 1560',
      'detalles': 'Salir a las 9:50',
    },
    {
      'title': 'Esperar a',
      'description': 'Ruta 25  Av. industrias',
      'detalles': '10:00, 10:25',
    },
    {
      'title': 'Ir a',
      'description': 'Macroplaza',
      'detalles': '14 Paradas - 11 minutos',
    },
  ];

  final List<double> progress = [1.0, 1.0, 0.6];

  bool isJourneyStarted = false;
  bool showRatingSheet = false;

  final commentController = TextEditingController();
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    final firstLocation = widget.ruta.locations.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ruta.nombre),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          // Mapa de fondo
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(firstLocation.latitude, firstLocation.longitude),
              zoom: 13,
            ),
            markers: {
              for (var loc in widget.ruta.locations)
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
                points:
                    widget.ruta.locations
                        .map((loc) => LatLng(loc.latitude, loc.longitude))
                        .toList(),
              ),
            },
          ),

          // Draggable sheet por encima del mapa
          if (!showRatingSheet)
            DraggableScrollableSheet(
              initialChildSize: isJourneyStarted ? 0.35 : 0.70,
              minChildSize: 0.2,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return BusRouteSheet(
                  isJourneyStarted: isJourneyStarted,
                  scrollController: scrollController,
                  busStops: busStops,
                  progress: progress,
                  onButtonPressed: () {
                    setState(() {
                      if (isJourneyStarted) {
                        showRatingSheet = true;
                      } else {
                        isJourneyStarted = true;
                      }
                    });
                  },
                );
              },
            )
          else
            DraggableScrollableSheet(
              initialChildSize: 0.80,
              maxChildSize: 0.85,
              minChildSize: 0.10,
              builder: (context, scrollController) {
                return RatingSheet(
                  scrollController: scrollController,
                  onSubmit: () {
                    setState(() {
                      showRatingSheet = false;
                      isJourneyStarted = false;
                    });
                    commentController.clear();
                    selectedRating = 0;
                  },
                  commentController: commentController,
                  selectedRating: selectedRating,
                  onRatingChanged: (rating) {
                    setState(() {
                      selectedRating = rating;
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
