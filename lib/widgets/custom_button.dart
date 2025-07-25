// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

/// Reusable custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // Primary or secondary button styling
          backgroundColor: isSecondary
              ? Colors.transparent
              : Theme.of(context).primaryColor,
          foregroundColor: isSecondary
              ? Theme.of(context).primaryColor
              : Colors.white,

          // Border for secondary button
          side: isSecondary
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : null,

          // Button shape and elevation
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: isSecondary ? 0 : 2,

          // Disable shadow for secondary button
          shadowColor: isSecondary ? Colors.transparent : null,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSecondary
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
