import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 30,
  });

  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      enableFeedback: true,
      onPressed: () async {
        await HapticFeedback.vibrate();
        onPressed();
      },
      icon: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(0xFF303030),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: Colors.white70),
      ),
    );
  }
}
