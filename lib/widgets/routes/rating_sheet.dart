import 'package:flutter/material.dart';

class RatingSheet extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onSubmit;
  final TextEditingController commentController;
  final int selectedRating;
  final Function(int) onRatingChanged;

  const RatingSheet({
    super.key,
    required this.scrollController,
    required this.onSubmit,
    required this.commentController,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: ListView(
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/Tp127eb40g.png', height: 120),
              const SizedBox(height: 16),
              const Text(
                '¿Cómo fue tu experiencia con esta ruta?',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating
                          ? Icons.star
                          : Icons.star_border_outlined,
                      color: Colors.amber,
                      size: 45,
                    ),
                    onPressed: () => onRatingChanged(index + 1),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Campo de comentarios
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tus comentarios aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.scaffoldBackgroundColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.scaffoldBackgroundColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA13CF2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
