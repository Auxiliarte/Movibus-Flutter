// lib/widgets/bus_route_sheet.dart

import 'package:flutter/material.dart';

class BusRouteSheet extends StatelessWidget {
  final bool isJourneyStarted;
  final ScrollController scrollController;
  final List<Map<String, String>> busStops;
  final List<double> progress;
  final VoidCallback onButtonPressed;

  const BusRouteSheet({
    super.key,
    required this.isJourneyStarted,
    required this.scrollController,
    required this.busStops,
    required this.progress,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            isJourneyStarted ? 'Comenzando' : 'Itinerario',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isJourneyStarted ? 20 : 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (isJourneyStarted) ...[
            const Center(
              child: Text(
                'El viaje está comenzando, por favor espere.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 50),
          ] else ...[
            Column(
              children: List.generate(busStops.length, (index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              index == 0
                                  ? Icons.location_on_outlined
                                  : index == 1
                                  ? Icons.access_time_outlined
                                  : Icons.directions_bus_outlined,
                              color: Colors.deepPurple,
                              size: 22,
                            ),
                          ),
                        ),
                        if (index != busStops.length - 1)
                          Container(
                            width: 6,
                            height: 60,
                            decoration: BoxDecoration(
                              color:
                                  progress[index] == 1.0
                                      ? Colors.deepPurple
                                      : Colors.deepPurple.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              busStops[index]['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              busStops[index]['description']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              busStops[index]['detalles']!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
          const SizedBox(height: 100),
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA13CF2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              isJourneyStarted ? 'Salir' : 'Comenzar viaje',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
