import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movibus/themes/app_colors.dart';
import 'package:movibus/widgets/Home/coupon_card.dart';
import 'package:movibus/widgets/Home/favorite_card.dart';
import 'package:movibus/widgets/Home/search_input.dart';
import 'package:movibus/widgets/Home/suggested_route_card.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';
import '../models/coupon.dart';
import '../services/coupon_service.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/routesHistory');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/settings');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://192.168.1.221:8000/api';
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
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/Avatars.png'),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SearchInput(
                    hint: "¿Dónde te encuentras?",
                    controller: _fromController,
                    onChanged: (text) => _checkInputs(),
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      SearchInput(
                        hint: "¿A dónde vas?",
                        controller: _toController,
                        onChanged: (text) => _checkInputs(),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.sync, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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
                      children: const [
                        Text(
                          "Cuponera",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Ver todo",
                          style: TextStyle(color: Colors.deepPurple),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
