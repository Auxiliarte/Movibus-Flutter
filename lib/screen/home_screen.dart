import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movibus/themes/app_colors.dart';
import '../models/coupon.dart';
import '../services/coupon_service.dart';
import '../widgets/coupon_card.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Nuevas variables para manejar la visibilidad de trayectos
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

  // Método para controlar la visibilidad de los trayectos cuando ambos inputs estén llenos
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
            // Sección superior
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
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/Avatars.png'),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _searchInput("¿Dónde te encuentras?", _fromController),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      _searchInput("¿A dónde vas?", _toController),
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

            // Solo mostrar los trayectos cuando ambos campos estén llenos
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
                    Column(
                      children: [
                        _suggestedRouteCard(
                          ruta: "Ruta #1",
                          salida: "Sale 3:00 de la Av. Industrial 1650",
                          tiempo: "30 minutos",
                          horaLlegada: "15:30",
                        ),
                        const SizedBox(height: 12),
                        _suggestedRouteCard(
                          ruta: "Ruta #2",
                          salida: "Sale 3:00 de la Av. chapultepec 1980",
                          tiempo: "25 minutos",
                          horaLlegada: "15:20",
                        ),
                        const SizedBox(height: 12),
                        _suggestedRouteCard(
                          ruta: "Ruta #3",
                          salida: "Sale 3:00 de la Av. México 230",
                          tiempo: "40 minutos",
                          horaLlegada: "15:50",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Mostrar el resto del contenido solo si los trayectos no están visibles
            Visibility(
              visible: !_isVisibleTrayectos,
              child: Column(
                children: [
                  // FAVORITOS
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _favoriteCard(
                        icon: Icons.home,
                        title: "Casa",
                        subtitle: "Malvas 112, fracc. Del Llano",
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _favoriteCard(
                      icon: Icons.work,
                      title: "Trabajo",
                      subtitle: "Venustiano Carranza 500, col. Centro",
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CUPONERA
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

                  // HISTORIAL
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
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
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
                          tileColor: Theme.of(context).dialogBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            Icons.access_time,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          title: Text(
                            "Ruta 24",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            "Av. Industrias 600",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hace 2 días",
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(fontSize: 12),
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

  Widget _searchInput(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (text) {
        _checkInputs(); // Verifica si los campos están llenos
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _suggestedRouteCard({
    required String ruta,
    required String salida,
    required String tiempo,
    required String horaLlegada,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromARGB(241, 255, 255, 255)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        ruta,

                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'quicksand',
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_right),
                  ],
                ),
                Text(
                  salida,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontFamily: 'quicksand',
                  ),
                ),
                const Divider(color: Color.fromARGB(255, 204, 203, 203)),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      " $tiempo",
                      style: TextStyle(
                        color: AppColors.darkInputFocus,
                        fontWeight: FontWeight.w500,
                        fontFamily: "quicksand",
                      ),
                    ),
                    Text(
                      "Llegada a las: $horaLlegada",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: "quicksand",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ],
      ),
    );
  }
}
