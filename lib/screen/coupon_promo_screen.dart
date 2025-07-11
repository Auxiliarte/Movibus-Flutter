import 'package:flutter/material.dart';
import 'package:moventra/themes/app_colors.dart';
import 'package:moventra/widgets/Home/coupon_card_list.dart';
import 'package:moventra/widgets/Home/coupon_promo_card.dart';
import 'package:moventra/widgets/custom_bottom_nav_bar.dart'; // Importa tu navbar

class CouponPromoHistorialScreen extends StatefulWidget {
  const CouponPromoHistorialScreen({super.key});

  @override
  State<CouponPromoHistorialScreen> createState() =>
      _CouponPromoHistorialScreenState();
}

class _CouponPromoHistorialScreenState
    extends State<CouponPromoHistorialScreen> {
  final List<bool> favoriteStates = [true, false]; // Estado para cada tarjeta
  String selectedCategory = "Todos";

  int _currentIndex = 0; // Estado para el navbar

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Aquí puedes hacer la navegación dependiendo del índice
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        children: [
          // AppBar personalizado
          Container(
            color: theme.secondaryHeaderColor,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  color: theme.iconTheme.color,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  "Cupones y Promociones",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Scroll horizontal de categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final category in [
                  "Todos",
                  "Comida",
                  "Ropa",
                  "Transporte",
                  "Tecnología",
                ])
                  CategoryButton(
                    label: category,
                    isSelected: selectedCategory == category,
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Contenedores de CUPONES
          CouponPromoCard(
            imagePath: 'assets/little_caesar.png',
            title: 'Little Caesar',
            subtitle: '10% de descuento en tu pizza de peperoni',
            rating: 4.8,
            isFavorite: true,
            onFavoriteToggle: () {},
          ),
          CouponPromoCard(
            imagePath: 'assets/promoda.png',
            title: 'Promoda',
            subtitle: '5% en pantalones',
            rating: 4.5,
            isFavorite: false,
            onFavoriteToggle: () {},
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
