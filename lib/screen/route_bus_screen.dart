import 'package:flutter/material.dart';
import 'package:moventra/widgets/routes/custom_draggable_sheet.dart';
import 'package:moventra/widgets/routes/rating_sheet.dart';

class BusRouteScreen extends StatefulWidget {
  const BusRouteScreen({super.key});

  @override
  State<BusRouteScreen> createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
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
      'detalles': '14 Paradas- 11 minutos',
    },
  ];

  final List<double> progress = [1.0, 1.0, 0.6];

  bool isJourneyStarted = false;
  bool showRatingSheet = false;

  final commentController = TextEditingController();
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
        children: [
          // Fondo
          Container(color: Colors.white),

          // Mostramos solo un Draggable a la vez
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
                    if (isJourneyStarted) {
                      setState(() {
                        showRatingSheet = true;
                      });
                    } else {
                      setState(() {
                        isJourneyStarted = true;
                      });
                    }
                  },
                );
              },
            )
          else
            DraggableScrollableSheet(
              initialChildSize: 0.80,
              maxChildSize: 0.85,
              minChildSize: 0.4,
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
      ),
    );
  }
}
