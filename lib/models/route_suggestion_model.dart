import 'station_model.dart';

class RouteSuggestionModel {
  final String tipo;
  final String ruta;
  final StationInfo subirEn;
  final StationInfo bajarseEn;
  final String tiempoEnCamion;
  final String tiempoTotal;
  final double puntuacion;
  final TrayectoInfo? trayecto;
  final TransbordoInfo? transbordo;

  RouteSuggestionModel({
    required this.tipo,
    required this.ruta,
    required this.subirEn,
    required this.bajarseEn,
    required this.tiempoEnCamion,
    required this.tiempoTotal,
    required this.puntuacion,
    this.trayecto,
    this.transbordo,
  });

  factory RouteSuggestionModel.fromJson(Map<String, dynamic> json) {
    return RouteSuggestionModel(
      tipo: json['tipo'] ?? 'directo',
      ruta: json['ruta'] ?? 'Ruta sin nombre',
      subirEn: StationInfo.fromJson(json['subir_en'] ?? {}),
      bajarseEn: StationInfo.fromJson(json['bajarse_en'] ?? {}),
      tiempoEnCamion: json['tiempo_en_camion'] ?? '0 minutos',
      tiempoTotal: json['tiempo_total'] ?? '0 minutos',
      puntuacion: (json['puntuacion'] ?? 0.0).toDouble(),
      trayecto: json['trayecto'] != null ? TrayectoInfo.fromJson(json['trayecto']) : null,
      transbordo: json['transbordo'] != null ? TransbordoInfo.fromJson(json['transbordo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'ruta': ruta,
      'subir_en': subirEn.toJson(),
      'bajarse_en': bajarseEn.toJson(),
      'tiempo_en_camion': tiempoEnCamion,
      'tiempo_total': tiempoTotal,
      'puntuacion': puntuacion,
      if (trayecto != null) 'trayecto': trayecto!.toJson(),
      if (transbordo != null) 'transbordo': transbordo!.toJson(),
    };
  }

  // Métodos de conveniencia para compatibilidad con código existente
  String get routeName => ruta;
  String get routeDescription => 'Ruta de transporte público';
  int get routeId => ruta.hashCode;
  int get totalStations => 0;
  StationModel get departureStation => StationModel(
    id: 1,
    latitude: subirEn.latitud ?? 0.0,
    longitude: subirEn.longitud ?? 0.0,
    order: 0,
    distanceMeters: _extractDistance(subirEn.distanciaCaminando),
    walkingTimeMinutes: _extractTime(subirEn.tiempoCaminando),
  );
  StationModel get arrivalStation => StationModel(
    id: 2,
    latitude: bajarseEn.latitud ?? 0.0,
    longitude: bajarseEn.longitud ?? 0.0,
    order: 1,
    distanceMeters: _extractDistance(bajarseEn.distanciaCaminando),
    walkingTimeMinutes: _extractTime(bajarseEn.tiempoCaminando),
  );
  String get direction => trayecto?.direccion ?? 'Dirección desconocida';
  int get stationsCount => trayecto?.totalEstaciones ?? 0;
  List<StationModel> get intermediateStations {
    if (trayecto == null) return [];
    return trayecto!.estaciones.map((estacion) => StationModel(
      id: estacion.orden,
      latitude: estacion.latitud,
      longitude: estacion.longitud,
      order: estacion.orden,
    )).toList();
  }
  double get estimatedBusTimeMinutes {
    // Extraer minutos del string "36 minutos"
    final match = RegExp(r'(\d+)').firstMatch(tiempoEnCamion);
    return match != null ? double.tryParse(match.group(1) ?? '0') ?? 0.0 : 0.0;
  }
  String get estimatedBusTimeFormatted => tiempoEnCamion;
  double get score => puntuacion;
  double get totalWalkingDistance {
    // Sumar distancias de caminar desde subirEn y bajarseEn
    final subirDist = _extractDistance(subirEn.distanciaCaminando);
    final bajarDist = _extractDistance(bajarseEn.distanciaCaminando);
    return subirDist + bajarDist;
  }
  double get estimatedTotalTime {
    // Extraer minutos del string "66 minutos"
    final match = RegExp(r'(\d+)').firstMatch(tiempoTotal);
    return match != null ? double.tryParse(match.group(1) ?? '0') ?? 0.0 : 0.0;
  }

  double _extractDistance(String distanceString) {
    // Extraer metros del string "2241 metros"
    final match = RegExp(r'(\d+)').firstMatch(distanceString);
    return match != null ? double.tryParse(match.group(1) ?? '0') ?? 0.0 : 0.0;
  }

  double _extractTime(String timeString) {
    // Extraer minutos del string "28 minutos"
    final match = RegExp(r'(\d+)').firstMatch(timeString);
    return match != null ? double.tryParse(match.group(1) ?? '0') ?? 0.0 : 0.0;
  }

  // Métodos para crear estaciones con coordenadas específicas (fallback)
  StationModel createDepartureStation(double latitude, double longitude) {
    return StationModel(
      id: 1,
      latitude: subirEn.latitud ?? latitude,
      longitude: subirEn.longitud ?? longitude,
      order: 0,
      distanceMeters: _extractDistance(subirEn.distanciaCaminando),
      walkingTimeMinutes: _extractTime(subirEn.tiempoCaminando),
    );
  }

  StationModel createArrivalStation(double latitude, double longitude) {
    return StationModel(
      id: 2,
      latitude: bajarseEn.latitud ?? latitude,
      longitude: bajarseEn.longitud ?? longitude,
      order: 1,
      distanceMeters: _extractDistance(bajarseEn.distanciaCaminando),
      walkingTimeMinutes: _extractTime(bajarseEn.tiempoCaminando),
    );
  }
}

class StationInfo {
  final String estacion;
  final String distanciaCaminando;
  final String tiempoCaminando;
  final double? latitud;
  final double? longitud;

  StationInfo({
    required this.estacion,
    required this.distanciaCaminando,
    required this.tiempoCaminando,
    this.latitud,
    this.longitud,
  });

  factory StationInfo.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? coordenadas = json['coordenadas'];
    return StationInfo(
      estacion: json['estacion'] ?? 'Estación desconocida',
      distanciaCaminando: json['distancia_caminando'] ?? '0 metros',
      tiempoCaminando: json['tiempo_caminando'] ?? '0 minutos',
      latitud: coordenadas?['latitud']?.toDouble(),
      longitud: coordenadas?['longitud']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estacion': estacion,
      'distancia_caminando': distanciaCaminando,
      'tiempo_caminando': tiempoCaminando,
      if (latitud != null && longitud != null)
        'coordenadas': {
          'latitud': latitud,
          'longitud': longitud,
        },
    };
  }
}

class TrayectoInfo {
  final String direccion;
  final List<EstacionTrayecto> estaciones;
  final int totalEstaciones;

  TrayectoInfo({
    required this.direccion,
    required this.estaciones,
    required this.totalEstaciones,
  });

  factory TrayectoInfo.fromJson(Map<String, dynamic> json) {
    return TrayectoInfo(
      direccion: json['direccion'] ?? 'ida',
      estaciones: (json['estaciones'] as List?)
          ?.map((estacion) => EstacionTrayecto.fromJson(estacion))
          .toList() ?? [],
      totalEstaciones: json['total_estaciones'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direccion': direccion,
      'estaciones': estaciones.map((e) => e.toJson()).toList(),
      'total_estaciones': totalEstaciones,
    };
  }
}

class EstacionTrayecto {
  final String estacion;
  final int orden;
  final double latitud;
  final double longitud;

  EstacionTrayecto({
    required this.estacion,
    required this.orden,
    required this.latitud,
    required this.longitud,
  });

  factory EstacionTrayecto.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> coordenadas = json['coordenadas'] ?? {};
    return EstacionTrayecto(
      estacion: json['estacion'] ?? 'Estación desconocida',
      orden: json['orden'] ?? 0,
      latitud: coordenadas['latitud']?.toDouble() ?? 0.0,
      longitud: coordenadas['longitud']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estacion': estacion,
      'orden': orden,
      'coordenadas': {
        'latitud': latitud,
        'longitud': longitud,
      },
    };
  }
}

class TransbordoInfo {
  final String estacionOrigen;
  final String estacionDestino;
  final String distanciaCaminando;
  final String tiempoCaminando;
  final double latitudOrigen;
  final double longitudOrigen;
  final double latitudDestino;
  final double longitudDestino;

  TransbordoInfo({
    required this.estacionOrigen,
    required this.estacionDestino,
    required this.distanciaCaminando,
    required this.tiempoCaminando,
    required this.latitudOrigen,
    required this.longitudOrigen,
    required this.latitudDestino,
    required this.longitudDestino,
  });

  factory TransbordoInfo.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> coordenadasOrigen = json['coordenadas_origen'] ?? {};
    Map<String, dynamic> coordenadasDestino = json['coordenadas_destino'] ?? {};
    
    return TransbordoInfo(
      estacionOrigen: json['estacion_origen'] ?? 'Estación origen',
      estacionDestino: json['estacion_destino'] ?? 'Estación destino',
      distanciaCaminando: json['distancia_caminando'] ?? '0 metros',
      tiempoCaminando: json['tiempo_caminando'] ?? '0 minutos',
      latitudOrigen: coordenadasOrigen['latitud']?.toDouble() ?? 0.0,
      longitudOrigen: coordenadasOrigen['longitud']?.toDouble() ?? 0.0,
      latitudDestino: coordenadasDestino['latitud']?.toDouble() ?? 0.0,
      longitudDestino: coordenadasDestino['longitud']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estacion_origen': estacionOrigen,
      'estacion_destino': estacionDestino,
      'distancia_caminando': distanciaCaminando,
      'tiempo_caminando': tiempoCaminando,
      'coordenadas_origen': {
        'latitud': latitudOrigen,
        'longitud': longitudOrigen,
      },
      'coordenadas_destino': {
        'latitud': latitudDestino,
        'longitud': longitudDestino,
      },
    };
  }
} 