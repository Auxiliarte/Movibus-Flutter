class RegionModel {
  final String id;
  final String name;
  final String displayName;
  final String country;
  final String countryCode;
  final String state;
  final double centerLatitude;
  final double centerLongitude;
  final int searchRadius; // Radio de búsqueda en metros
  final double defaultZoom;
  final List<String> searchTerms; // Términos para filtrar búsquedas
  final bool isActive;

  const RegionModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.country,
    required this.countryCode,
    required this.state,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.searchRadius,
    required this.defaultZoom,
    required this.searchTerms,
    this.isActive = true,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
      country: json['country'],
      countryCode: json['country_code'],
      state: json['state'],
      centerLatitude: double.tryParse(json['center_latitude'].toString()) ?? 0.0,
      centerLongitude: double.tryParse(json['center_longitude'].toString()) ?? 0.0,
      searchRadius: json['search_radius'] ?? 50000,
      defaultZoom: double.tryParse(json['default_zoom'].toString()) ?? 12.0,
      searchTerms: List<String>.from(json['search_terms'] ?? []),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'country': country,
      'country_code': countryCode,
      'state': state,
      'center_latitude': centerLatitude,
      'center_longitude': centerLongitude,
      'search_radius': searchRadius,
      'default_zoom': defaultZoom,
      'search_terms': searchTerms,
      'is_active': isActive,
    };
  }

  // Método para verificar si un texto contiene términos de esta región
  bool containsRegionTerms(String text) {
    final lowerText = text.toLowerCase();
    return searchTerms.any((term) => lowerText.contains(term.toLowerCase()));
  }

  // Crear string de búsqueda para Google Places
  String formatSearchInput(String input) {
    if (containsRegionTerms(input)) {
      return input;
    }
    return '$input, $displayName, $state';
  }

  @override
  String toString() {
    return '$displayName, $state';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Regiones predefinidas
  static const RegionModel sanLuisPotosi = RegionModel(
    id: 'slp_mx',
    name: 'san_luis_potosi',
    displayName: 'San Luis Potosí',
    country: 'México',
    countryCode: 'mx',
    state: 'San Luis Potosí',
    centerLatitude: 22.1565,
    centerLongitude: -100.9855,
    searchRadius: 50000,
    defaultZoom: 12.0,
    searchTerms: ['san luis potosí', 'slp', 'potosí'],
  );

  static const RegionModel guadalajara = RegionModel(
    id: 'gdl_mx',
    name: 'guadalajara',
    displayName: 'Guadalajara',
    country: 'México',
    countryCode: 'mx',
    state: 'Jalisco',
    centerLatitude: 20.6597,
    centerLongitude: -103.3496,
    searchRadius: 50000,
    defaultZoom: 12.0,
    searchTerms: ['guadalajara', 'gdl', 'jalisco'],
  );

  static const RegionModel mexicoCity = RegionModel(
    id: 'cdmx_mx',
    name: 'mexico_city',
    displayName: 'Ciudad de México',
    country: 'México',
    countryCode: 'mx',
    state: 'Ciudad de México',
    centerLatitude: 19.4326,
    centerLongitude: -99.1332,
    searchRadius: 80000,
    defaultZoom: 11.0,
    searchTerms: ['ciudad de méxico', 'cdmx', 'méxico df', 'distrito federal'],
  );

  static const RegionModel monterrey = RegionModel(
    id: 'mty_mx',
    name: 'monterrey',
    displayName: 'Monterrey',
    country: 'México',
    countryCode: 'mx',
    state: 'Nuevo León',
    centerLatitude: 25.6866,
    centerLongitude: -100.3161,
    searchRadius: 50000,
    defaultZoom: 12.0,
    searchTerms: ['monterrey', 'mty', 'nuevo león'],
  );

  static const RegionModel puebla = RegionModel(
    id: 'pue_mx',
    name: 'puebla',
    displayName: 'Puebla',
    country: 'México',
    countryCode: 'mx',
    state: 'Puebla',
    centerLatitude: 19.0413,
    centerLongitude: -98.2062,
    searchRadius: 50000,
    defaultZoom: 12.0,
    searchTerms: ['puebla', 'pue'],
  );

  static const RegionModel bogota = RegionModel(
    id: 'bog_co',
    name: 'bogota',
    displayName: 'Bogotá',
    country: 'Colombia',
    countryCode: 'co',
    state: 'Cundinamarca',
    centerLatitude: 4.7110,
    centerLongitude: -74.0721,
    searchRadius: 60000,
    defaultZoom: 11.0,
    searchTerms: ['bogotá', 'bogota', 'cundinamarca'],
  );

  static const RegionModel medellin = RegionModel(
    id: 'med_co',
    name: 'medellin',
    displayName: 'Medellín',
    country: 'Colombia',
    countryCode: 'co',
    state: 'Antioquia',
    centerLatitude: 6.2442,
    centerLongitude: -75.5812,
    searchRadius: 50000,
    defaultZoom: 12.0,
    searchTerms: ['medellín', 'medellin', 'antioquia'],
  );

  static const RegionModel cali = RegionModel(
    id: 'cal_co',
    name: 'cali',
    displayName: 'Cali',
    country: 'Colombia',
    countryCode: 'co',
    state: 'Valle del Cauca',
    centerLatitude: 3.4516,
    centerLongitude: -76.5320,
    searchRadius: 50000,
    defaultZoom: 12.0,
    searchTerms: ['cali', 'valle del cauca'],
  );

  // Lista de todas las regiones disponibles
  static const List<RegionModel> availableRegions = [
    sanLuisPotosi,
    guadalajara,
    mexicoCity,
    monterrey,
    puebla,
    bogota,
    medellin,
    cali,
  ];

  // Obtener región por ID
  static RegionModel? getById(String id) {
    try {
      return availableRegions.firstWhere((region) => region.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener región por nombre
  static RegionModel? getByName(String name) {
    try {
      return availableRegions.firstWhere(
        (region) => region.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
