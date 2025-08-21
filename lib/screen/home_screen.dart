import 'dart:io';
import 'package:flutter/material.dart';
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
import '../services/coupon_service.dart';
import '../services/location_service.dart';
import 'package:moventra/widgets/Home/place_autocomplete_field.dart';
import 'package:moventra/widgets/Home/help_modal.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'destination_confirmation_screen.dart';
import 'google_maps_test_screen.dart';

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
  
  // Coordenadas para las rutas sugeridas
  double? _fromLatitude;
  double? _fromLongitude;
  double? _toLatitude;
  double? _toLongitude;

  // Estado para mostrar información de ubicación
  String? _currentLocationAddress;
  bool _isLoadingLocation = false;
  bool _showHelp = true; // Mostrar ayuda la primera vez


  @override
  void initState() {
    super.initState();
    // Intentar obtener ubicación actual al iniciar
    _getCurrentLocation();
    
    // Mostrar modal de ayuda después de un breve delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _showHelp) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const HelpModal(isVisible: true),
          ).then((_) {
            // Ocultar ayuda después de completar el tutorial
            if (mounted) {
              setState(() {
                _showHelp = false;
              });
            }
          });
        }
      });
    });
  }

  Future<void> _getCurrentLocation() async {
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
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      // No mostrar error aquí, el usuario puede ingresar manualmente
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

  void _checkInputs() {
    setState(() {
      _isVisibleTrayectos =
          _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
    });
  }

  void _onOriginSelected(String name, double lat, double lng) {
    setState(() {
      _fromLatitude = lat;
      _fromLongitude = lng;
      _showHelp = false; // Ocultar ayuda cuando el usuario selecciona origen
      _checkInputs();
    });
  }

  void _onDestinationSelected(String name, double lat, double lng) async {
    print('🎯 Destination selected: $name at ($lat, $lng)');
    
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

    print('🎯 About to navigate to confirmation screen...');
    
    try {
      // Navegar a la pantalla de confirmación del destino
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => DestinationConfirmationScreen(
            originLat: _fromLatitude ?? 22.1565,
            originLng: _fromLongitude ?? -100.9855,
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
      } else {
        // El usuario canceló, revertir cambios
        setState(() {
          _toLatitude = null;
          _toLongitude = null;
          _toController.clear();
          _isVisibleTrayectos = false;
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

  void _showHelpModal() {
    showDialog(
      context: context,
      builder: (context) => const HelpModal(isVisible: true),
    );
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
            // Ocultar ayuda después de completar el tutorial
            setState(() {
              _showHelp = false;
            });
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
                      Text(
                        'Hola José',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
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
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const GoogleMapsTestScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.map,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Probar Google Maps',
                          ),
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage('assets/Avatars.png'),
                            backgroundColor: Colors.transparent,
                          ),
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
                        Text(
                          "Agregar",
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FavoriteCard(
                      icon: Icons.home,
                      title: "Casa",
                      subtitle: "Malvas 112, fracc. Del Llano",
                    ),
                    const SizedBox(height: 8),
                    FavoriteCard(
                      icon: Icons.work,
                      title: "Trabajo",
                      subtitle: "Venustiano Carranza 500, col. Centro",
                    ),
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
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Historial",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Icon(
                          Icons.delete_outline,
                          size: 25,
                          color: Color(0xFFA13CF2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, '/routes');
                      },
                      tileColor: theme.dialogTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        Icons.access_time,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      title: Text(
                        "Ruta 24",
                        style: theme.textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        "Av. Industrias 600",
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Hace 2 días",
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
