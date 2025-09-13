import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moventra/themes/app_colors.dart';
import 'package:moventra/widgets/Home/coupon_card.dart';
import 'package:moventra/widgets/Home/favorite_card.dart';
import 'package:moventra/widgets/Home/search_input.dart';
import 'package:moventra/widgets/Home/enhanced_search_input.dart';
import 'package:moventra/widgets/Home/suggested_route_card.dart';
import 'package:moventra/widgets/Home/nearest_station_widget.dart';
import 'package:moventra/widgets/Home/route_suggestions_widget.dart';
import 'package:moventra/widgets/custom_bottom_nav_bar.dart';
import '../models/coupon.dart';
import '../models/favorite_location.dart';
import '../models/route_suggestion_model.dart';
import '../services/coupon_service.dart';
import '../services/location_service.dart';
import '../services/location_api_service.dart';
import '../services/favorite_service.dart';
import '../services/region_service.dart';
import 'package:moventra/widgets/Home/place_autocomplete_field.dart';
import 'add_favorite_screen.dart';
import 'package:moventra/widgets/Home/help_modal.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'destination_confirmation_screen.dart';
import 'route_detail_screen.dart';
import 'package:moventra/services/auth_service.dart';
import 'package:moventra/services/profile_api_service.dart';
import 'package:moventra/models/user_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  bool _isVisibleTrayectos = false;
  bool _autoSearchRoutes = false;
  
  // Coordenadas para las rutas sugeridas
  double? _fromLatitude;
  double? _fromLongitude;
  double? _toLatitude;
  double? _toLongitude;

  // Estado para mostrar información de ubicación
  String? _currentLocationAddress;
  bool _isLoadingLocation = false;
  bool _showHelp = false; // Se determinará basado en SharedPreferences

  // Estado para favoritos
  List<FavoriteLocation> _favorites = [];
  bool _isLoadingFavorites = false;
  String? _favoritesError;

  // Estado para el perfil del usuario
  String? _userToken; // ignore: unused_field - Usado internamente para autenticación en la API
  UserProfile? _userProfile;
  bool _isLoadingProfile = false;
  String? _profileError;
  final AuthService _authService = AuthService();
  final ProfileApiService _profileApiService = ProfileApiService();


  @override
  void initState() {
    super.initState();
    // Cargar perfil del usuario
    _loadUserProfile();
    // Intentar obtener ubicación actual al iniciar
    _getCurrentLocation();
    // Cargar favoritos
    _loadFavorites();
    // Verificar si mostrar el tutorial
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;
      
      if (!hasSeenTutorial) {
        setState(() {
          _showHelp = true;
        });
        
        // Mostrar modal de ayuda después de un breve delay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _showHelp) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const HelpModal(isVisible: true),
              ).then((_) {
                // Marcar que ya se vio el tutorial y ocultar ayuda
                _markTutorialAsSeen();
              });
            }
          });
        });
      }
    } catch (e) {
      print('Error checking first time user: $e');
    }
  }

  Future<void> _markTutorialAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_tutorial', true);
      
      if (mounted) {
        setState(() {
          _showHelp = false;
        });
      }
      
      print('✅ Tutorial marked as seen');
    } catch (e) {
      print('Error marking tutorial as seen: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    // 🚨 SOLUCIÓN: No sobreescribir si el usuario ya seleccionó una ubicación
    if (_fromLatitude != null && _fromLongitude != null &&
        _fromController.text.isNotEmpty &&
        !_fromController.text.contains('Mi ubicación actual')) {
      print('⏭️ Skipping current location - user has selected custom location: (${_fromLatitude}, $_fromLongitude) - ${_fromController.text}');
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _fromLatitude = position.latitude;
          _fromLongitude = position.longitude;
          _currentLocationAddress = address ?? 'Mi ubicación actual';
          _fromController.text = _currentLocationAddress!;
          _isLoadingLocation = false;
        });

        _checkInputs();
        print('✅ Set current location: (${_fromLatitude}, $_fromLongitude) - ${_currentLocationAddress}');
        
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('❌ Error getting current location: $e');
      
      // Mostrar mensaje de error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('Permisos') 
                ? 'Se necesitan permisos de ubicación para usar esta función'
                : 'No se pudo obtener la ubicación. Verifica que el GPS esté habilitado.',
            ),
            backgroundColor: Colors.orange,
            action: e.toString().contains('Permisos')
              ? SnackBarAction(
                  label: 'Configurar',
                  textColor: Colors.white,
                  onPressed: () async {
                    await LocationService.openAppSettings();
                  },
                )
              : null,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      // Obtener token de autenticación
      final token = await _authService.getToken();
      if (token == null) {
        print('No se encontró token de autenticación');
        return;
      }

      if (mounted) {
        setState(() {
          _userToken = token;
          _isLoadingProfile = true;
          _profileError = null;
        });
      }

      // Obtener perfil del usuario
      final profile = await _profileApiService.getProfile(token);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }

      print('✅ Perfil de usuario cargado: ${profile.fullName}');
    } catch (e) {
      print('❌ Error al cargar perfil de usuario: $e');
      if (mounted) {
        setState(() {
          _profileError = e.toString();
          _isLoadingProfile = false;
        });
      }
    }
  }

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

  void _checkInputs() {
    setState(() {
      _isVisibleTrayectos =
          _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
    });
  }

  void _onOriginSelected(String name, double lat, double lng) {
    print('🎯 Origin selected: $name at ($lat, $lng)');
    print('🎯 Previous origin: _fromLatitude=$_fromLatitude, _fromLongitude=$_fromLongitude');
    print('🎯 Previous origin text: ${_fromController.text}');

    setState(() {
      _fromLatitude = lat;
      _fromLongitude = lng;
      _fromController.text = name;
      if (_showHelp) {
        _markTutorialAsSeen(); // Marcar tutorial como visto cuando el usuario selecciona origen
      }
      _checkInputs();
    });

    print('✅ Origin updated to: ($lat, $lng) - $name');
  }

  void _onDestinationSelected(String name, double lat, double lng) async {
    print('🎯 Destination selected: $name at ($lat, $lng)');
    print('🎯 Current origin coordinates: _fromLatitude=$_fromLatitude, _fromLongitude=$_fromLongitude');
    print('🎯 Current origin address: ${_fromController.text}');

    // Verificar si tenemos coordenadas válidas del origen
    if (_fromLatitude == null || _fromLongitude == null) {
      print('⚠️  No origin coordinates available, trying to get current location...');
      print('⚠️  Origin text: ${_fromController.text}');

      // Si no hay coordenadas pero sí hay texto en el campo, intentar obtener ubicación actual
      final currentPosition = await LocationService.getCurrentLocation();
      if (currentPosition != null) {
        setState(() {
          _fromLatitude = currentPosition.latitude;
          _fromLongitude = currentPosition.longitude;
          if (_fromController.text.isEmpty || _fromController.text == "Mi ubicación actual") {
            _fromController.text = "Mi ubicación actual";
          }
        });
        print('✅ Got current location: ($_fromLatitude, $_fromLongitude)');
      } else {
        print('❌ Could not get current location, using default region coordinates');
        final region = RegionService.currentRegion;
        setState(() {
          _fromLatitude = region.centerLatitude;
          _fromLongitude = region.centerLongitude;
          if (_fromController.text.isEmpty) {
            _fromController.text = region.displayName;
          }
        });
      }
    } else {
      print('✅ Using existing origin coordinates: ($_fromLatitude, $_fromLongitude) - ${_fromController.text}');
    }

    // Ocultar teclado antes de continuar
    FocusScope.of(context).unfocus();

    // Pequeño delay para asegurar que el teclado se oculte completamente
    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      _toLatitude = lat;
      _toLongitude = lng;
      _toController.text = name;
      _isVisibleTrayectos = true;
    });

    // Verificar que el widget aún está montado antes de navegar
    if (!mounted) return;

    print('🎯 About to navigate to confirmation screen with:');
    print('   Origin: (${_fromLatitude}, ${_fromLongitude}) - ${_fromController.text}');
    print('   Destination: ($lat, $lng) - $name');

    try {
      // Navegar a la pantalla de confirmación del destino
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => DestinationConfirmationScreen(
            originLat: _fromLatitude!,
            originLng: _fromLongitude!,
            destinationLat: lat,
            destinationLng: lng,
            originAddress: _fromController.text.isNotEmpty ? _fromController.text : null,
            destinationAddress: name,
          ),
        ),
      );
      
      print('🎯 Navigation completed, result: $result');

          if (result != null) {
      // El usuario confirmó el destino
      setState(() {
        _toLatitude = result['latitude'] as double;
        _toLongitude = result['longitude'] as double;
        _toController.text = result['address'] as String;
        _isVisibleTrayectos = true;
        // Activar búsqueda automática si viene el flag
        _autoSearchRoutes = result['autoSearch'] == true;
      });
      
      // Mostrar mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Destino confirmado: ${result['address']}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Log para debugging
      if (_autoSearchRoutes) {
        print('🎯 Auto-search activated - routes will be searched automatically');
      }
      
    } else {
      // El usuario canceló, revertir cambios
      setState(() {
        _toLatitude = null;
        _toLongitude = null;
        _toController.clear();
        _isVisibleTrayectos = false;
        _autoSearchRoutes = false;
      });
    }
    } catch (e) {
      print('❌ Error during navigation: $e');
      // En caso de error, simplemente confirmar el destino sin navegar
      setState(() {
        _toLatitude = lat;
        _toLongitude = lng;
        _toController.text = name;
        _isVisibleTrayectos = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Destino seleccionado: $name'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _showHelp ? HelpButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const HelpModal(isVisible: true),
          ).then((_) {
            // Marcar que ya se vio el tutorial y ocultar ayuda
            _markTutorialAsSeen();
          });
        },
      ) : null,
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(color: theme.cardColor),
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildDynamicGreeting(),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                            icon: _isLoadingLocation 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 24,
                                ),
                            tooltip: 'Actualizar ubicación actual',
                          ),

                          _buildUserAvatar(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de origen
                  PlaceAutocompleteField(
                    hint: "¿Dónde te encuentras?",
                    controller: _fromController,
                    isOrigin: true,
                    onPlaceSelected: _onOriginSelected,
                  ),
                  const SizedBox(height: 12),
                  
                  // Campo de destino
                  PlaceAutocompleteField(
                    hint: "¿A dónde vas?",
                    controller: _toController,
                    isOrigin: false,
                    onPlaceSelected: _onDestinationSelected,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Widget de estación más cercana (solo mostrar si no hay destino seleccionado)
            if (!_isVisibleTrayectos)
              NearestStationWidget(
                userLatitude: _fromLatitude,
                userLongitude: _fromLongitude,
                userAddress: _currentLocationAddress,
              ),

            // Widget de rutas sugeridas (solo se muestra cuando hay destino)
            if (_isVisibleTrayectos)
              RouteSuggestionsWidget(
                destinationAddress: _toController.text.isNotEmpty ? _toController.text : null,
                destinationLatitude: _toLatitude,
                destinationLongitude: _toLongitude,
                userLatitude: _fromLatitude,
                userLongitude: _fromLongitude,
                autoSearch: _autoSearchRoutes,
                onAutoSearchCompleted: () {
                  // Resetear el flag después de completar la búsqueda automática
                  setState(() {
                    _autoSearchRoutes = false;
                  });
                  print('🎯 Auto-search completed and flag reset');
                },
              ),

            // Contenido cuando no hay trayectos seleccionados
            if (!_isVisibleTrayectos) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Favoritos", style: theme.textTheme.titleMedium),
                        TextButton(
                          onPressed: _showAddFavoriteModal,
                          child: Text(
                            "Agregar",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFavoritesSection(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cuponera",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/couponHistory');
                      },
                      child: const Text(
                        "Ver todo",
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: FutureBuilder<List<Coupon>>(
                  future: CouponService.fetchCoupons(getBackendUrl()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Text("Error al cargar cupones");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No hay cupones disponibles");
                    }

                    final cupones = snapshot.data!;
                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cupones.length,
                        itemBuilder: (context, index) {
                          return CouponCard(coupon: cupones[index]);
                        },
                      ),
                    );
                  },
                ),
              ),

            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicGreeting() {
    final theme = Theme.of(context);

    if (_isLoadingProfile) {
      return Text(
        'Cargando...',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (_profileError != null || _userProfile == null) {
      return Text(
        'Hola Usuario',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      'Hola ${_userProfile!.name}',
      style: theme.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserAvatar() {
    Widget avatar;

    if (_isLoadingProfile) {
      avatar = const CircleAvatar(
        radius: 25,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (_profileError != null || _userProfile == null || _userProfile!.profilePhotoUrl == null) {
      avatar = const CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage('assets/Avatars.png'),
        backgroundColor: Colors.transparent,
      );
    } else {
      avatar = CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(_userProfile!.profilePhotoUrl!),
        backgroundColor: Colors.transparent,
        onBackgroundImageError: (exception, stackTrace) {
          print('Error cargando imagen de perfil en home: $exception');
        },
        child: Container(), // Container vacío para evitar icono sobre imagen
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/profile');
      },
      child: avatar,
    );
  }

  // Métodos para manejar favoritos
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoadingFavorites = true;
      _favoritesError = null;
    });

    try {
      final favorites = await FavoriteService().getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoadingFavorites = false;
      });
    } catch (e) {
      setState(() {
        _favoritesError = e.toString();
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _deleteFavorite(int id) async {
    try {
      await FavoriteService().deleteFavorite(id);
      await _loadFavorites(); // Recargar la lista
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación favorita eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onFavoriteTap(FavoriteLocation favorite) async {
    // Mostrar indicador de carga
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Obtener ubicación actual del usuario
      final currentPosition = await LocationService.getCurrentLocation();
      double userLat, userLng;

      if (currentPosition != null) {
        userLat = currentPosition.latitude;
        userLng = currentPosition.longitude;
      } else {
        // Coordenadas por defecto de la región actual si no hay GPS
        final region = RegionService.currentRegion;
        userLat = region.centerLatitude;
        userLng = region.centerLongitude;
      }

      // El favorito será el destino
      final destinationAddress = favorite.address;
      _toController.text = favorite.address;
      _toLatitude = favorite.latitude;
      _toLongitude = favorite.longitude;

      // Usar ubicación actual como origen
      _fromController.text = "Mi ubicación actual";
      _fromLatitude = userLat;
      _fromLongitude = userLng;

      // Hacer la sugerencia de ruta con ubicación actual → favorito
      final result = await LocationApiService.suggestRoute(
        userLatitude: userLat,
        userLongitude: userLng,
        destinationLatitude: favorite.latitude,
        destinationLongitude: favorite.longitude,
        maxWalkingDistance: 1000, // 1 km máximo caminando
      );

      if (result['status'] == 'success' && result['data'] != null) {
        final data = result['data'];
        if (data is List && data.isNotEmpty) {
          // Tomar la primera sugerencia
          final suggestion = RouteSuggestionModel.fromJson(data[0]);

          if (mounted) {
            // Navegar directamente a los detalles de la ruta
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RouteDetailScreen(
                  routeSuggestion: suggestion,
                  destinationAddress: destinationAddress,
                  userLatitude: userLat,
                  userLongitude: userLng,
                  destinationLatitude: favorite.latitude,
                  destinationLongitude: favorite.longitude,
                ),
              ),
            );
          }
        } else {
          _showError('No se encontraron rutas para esta ubicación');
        }
      } else {
        _showError('Error al buscar rutas. Intenta de nuevo.');
      }

    } catch (e) {
      print('Error en _onFavoriteTap: $e');
      _showError('Error al procesar la ubicación favorita');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void _showAddFavoriteModal() async {
    final result = await Navigator.push<FavoriteLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddFavoriteScreen(),
      ),
    );

    if (result != null) {
      // Recargar la lista de favoritos después de agregar uno nuevo
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ubicación favorita "${result.name}" guardada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildFavoritesSection() {
    if (_favoritesError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error al cargar favoritos: $_favoritesError',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            IconButton(
              onPressed: _loadFavorites,
              icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      );
    }

    if (_isLoadingFavorites) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Cargando favoritos...'),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.location_on_outlined, color: Colors.grey),
            SizedBox(width: 12),
            Text('No tienes ubicaciones favoritas'),
          ],
        ),
      );
    }

    return Column(
      children: _favorites.map((favorite) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FavoriteCard(
            favorite: favorite,
            onTap: () => _onFavoriteTap(favorite),
            onDelete: () => _deleteFavorite(favorite.id),
          ),
        );
      }).toList(),
    );
  }
}
