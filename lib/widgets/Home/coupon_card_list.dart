import 'package:flutter/material.dart';
import 'package:movibus/themes/app_colors.dart';

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected
                  ? AppColors.darkProfileHeader
                  : AppColors.darkInputFocus,
          foregroundColor: theme.focusColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}
