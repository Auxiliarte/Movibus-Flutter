import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movibus/themes/app_colors.dart';
import 'package:movibus/widgets/Home/coupon_card.dart';
import 'package:movibus/widgets/Home/favorite_card.dart';
import 'package:movibus/widgets/Home/search_input.dart';
import 'package:movibus/widgets/Home/enhanced_search_input.dart';
import 'package:movibus/widgets/Home/suggested_route_card.dart';
import 'package:movibus/widgets/Home/nearest_station_widget.dart';
import 'package:movibus/widgets/Home/route_suggestions_widget.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';
import '../models/coupon.dart';
import '../services/coupon_service.dart';
import '../services/location_service.dart';
import 'package:movibus/widgets/Home/place_autocomplete_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  bool _isVisibleTrayectos = false;
  
  // Coordenadas para las rutas sugeridas
  double? _fromLatitude;
  double? _fromLongitude;
  double? _toLatitude;
  double? _toLongitude;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
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
                            onPressed: () {
                              Navigator.pushNamed(context, '/locationTest');
                            },
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Prueba de API de Ubicación',
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
                  PlaceAutocompleteField(
                    hint: "¿Dónde te encuentras?",
                    controller: _fromController,
                    onPlaceSelected: (name, lat, lng) {
                      setState(() {
                        _fromLatitude = lat;
                        _fromLongitude = lng;
                        _checkInputs();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  PlaceAutocompleteField(
                    hint: "¿A dónde vas?",
                    controller: _toController,
                    onPlaceSelected: (name, lat, lng) {
                      setState(() {
                        _toLatitude = lat;
                        _toLongitude = lng;
                        _checkInputs();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Widget de estación más cercana
            const NearestStationWidget(),

            // Widget de rutas sugeridas (solo se muestra cuando hay destino)
            Visibility(
              visible: _isVisibleTrayectos,
              child: RouteSuggestionsWidget(
                destinationAddress: _toController.text.isNotEmpty ? _toController.text : null,
                destinationLatitude: _toLatitude,
                destinationLongitude: _toLongitude,
              ),
            ),

            // Trayectos sugeridos originales (mantener como fallback)
            Visibility(
              visible: _isVisibleTrayectos,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trayectos sugeridos",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SuggestedRouteCard(
                      ruta: "Ruta #1",
                      salida: "Sale 3:00 de la Av. Industrial 1650",
                      tiempo: "30 minutos",
                      horaLlegada: "15:30",
                    ),
                    const SizedBox(height: 12),
                    const SuggestedRouteCard(
                      ruta: "Ruta #2",
                      salida: "Sale 3:00 de la Av. chapultepec 1980",
                      tiempo: "25 minutos",
                      horaLlegada: "15:20",
                    ),
                    const SizedBox(height: 12),
                    const SuggestedRouteCard(
                      ruta: "Ruta #3",
                      salida: "Sale 3:00 de la Av. México 230",
                      tiempo: "40 minutos",
                      horaLlegada: "15:50",
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: !_isVisibleTrayectos,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Favoritos", style: theme.textTheme.titleMedium),
                        Text(
                          "Agregar",
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FavoriteCard(
                      icon: Icons.home,
                      title: "Casa",
                      subtitle: "Malvas 112, fracc. Del Llano",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FavoriteCard(
                      icon: Icons.work,
                      title: "Trabajo",
                      subtitle: "Venustiano Carranza 500, col. Centro",
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Text("Error al cargar cupones");
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text("No hay cupones disponibles");
                        }

                        final cupones = snapshot.data!;
                        return SizedBox(
                          height: 110,
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
                          tileColor: theme.dialogBackgroundColor,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
