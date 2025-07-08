import 'package:flutter/material.dart';
import 'package:movibus/themes/app_colors.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _currentIndex = 3;

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

  final List<String> months = [
    "Enero 2025",
    "Febrero 2025",
    "Marzo 2025",
    "Abril 2025",
    "Mayo 2025",
  ];

  final Map<String, double> monthlyData = {
    "Enero 2025": 0.2,
    "Febrero 2025": 0.3,
    "Marzo 2025": 0.8,
    "Abril 2025": 0.3,
    "Mayo 2025": 0.2,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const selectedMonth = "Marzo 2025";
    // Obtener el mes con el mayor valor
    final maxEntry = monthlyData.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final maxMonth = maxEntry.key;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Contenedor de gráficas horizontales
            Container(
              color: AppColors.darkBodyBackground,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.darkInputBorder,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    "Estadísticas",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: theme.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Versiones de la aplicación",
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  // Selector de mes
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          " $selectedMonth",
                          style: TextStyle(color: AppColors.darkTextDisabled),
                        ),
                        children:
                            months.map((month) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(month),
                                selected: month == selectedMonth,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _horizontalBar("Premium", 0.7, const Color(0xFF7257FF)),
                  const SizedBox(height: 12),
                  _horizontalBar("Free", 0.3, const Color(0xFFDBD4FF)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contenedor de gráficas verticales y resumen
            Container(
              padding: const EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Suscripciones",
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Enero 30 - Marzo 30",
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder:
                                    (_) => Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Text("Opciones"),
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos resumidos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\$2,560",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Quicksand',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "MXN por día",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            "29.26%",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Etiquetas
                  Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7257FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text("Dataset: 1"),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: const Color(0xFFDBD4FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text("Dataset: 2"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gráficas de barras verticales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        months.map((month) {
                          final percentage =
                              monthlyData[month] ??
                              0.01; // Usamos 'month' directamente
                          final height = percentage * 200;
                          final value = (percentage * 200).round();

                          final isMax = month == maxMonth;

                          final barColor =
                              isMax
                                  ? const Color(0xFF7257FF)
                                  : const Color(0xFFDBD4FF);
                          final textColor =
                              isMax ? const Color(0xFF7257FF) : Colors.grey;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 200,
                                  width: 23,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "$value",
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            height: height,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: barColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  month.substring(
                                    0,
                                    3,
                                  ), // Mostrar el nombre del mes de manera corta
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Barra horizontal personalizada
  Widget _horizontalBar(String label, double percentage, Color color) {
    final percentageText = "${(percentage * 100).toStringAsFixed(0)}%";
    final barWidth =
        percentage *
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width *
        0.6;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            percentageText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                height: 30,
                width: barWidth,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(label, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
