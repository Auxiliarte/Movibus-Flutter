import 'station_model.dart';

class RouteSuggestionModel {
  final int routeId;
  final String routeName;
  final String routeDescription;
  final int totalStations;
  final StationModel departureStation;
  final StationModel arrivalStation;
  final String direction;
  final int stationsCount;
  final List<StationModel> intermediateStations;
  final double estimatedBusTimeMinutes;
  final String estimatedBusTimeFormatted;
  final double score;
  final double totalWalkingDistance;
  final double estimatedTotalTime;

  RouteSuggestionModel({
    required this.routeId,
    required this.routeName,
    required this.routeDescription,
    required this.totalStations,
    required this.departureStation,
    required this.arrivalStation,
    required this.direction,
    required this.stationsCount,
    required this.intermediateStations,
    required this.estimatedBusTimeMinutes,
    required this.estimatedBusTimeFormatted,
    required this.score,
    required this.totalWalkingDistance,
    required this.estimatedTotalTime,
  });

  factory RouteSuggestionModel.fromJson(Map<String, dynamic> json) {
    final route = json['route'];
    final departureStation = json['departure_station'];
    final arrivalStation = json['arrival_station'];
    final journey = json['journey'];

    return RouteSuggestionModel(
      routeId: route['id'],
      routeName: route['name'],
      routeDescription: route['description'],
      totalStations: route['total_stations'],
      departureStation: StationModel.fromJson(departureStation),
      arrivalStation: StationModel.fromJson(arrivalStation),
      direction: journey['direction'],
      stationsCount: journey['stations_count'],
      intermediateStations: (journey['intermediate_stations'] as List?)
          ?.map((station) => StationModel.fromJson(station))
          .toList() ?? [],
      estimatedBusTimeMinutes: journey['estimated_bus_time_minutes']?.toDouble() ?? 0.0,
      estimatedBusTimeFormatted: journey['estimated_bus_time_formatted'] ?? '',
      score: json['score']?.toDouble() ?? 0.0,
      totalWalkingDistance: json['total_walking_distance']?.toDouble() ?? 0.0,
      estimatedTotalTime: json['estimated_total_time']?.toDouble() ?? 0.0,
    );
  }
} 