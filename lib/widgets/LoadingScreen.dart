import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const double _kSize = 90.0;

    return Scaffold(
      backgroundColor: const Color(0xFF2E0E6B),
      body: Center(
        child: LoadingAnimationWidget.beat(color: Colors.white, size: _kSize),
      ),
    );
  }
}
