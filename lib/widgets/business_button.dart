import 'package:flutter/material.dart';

class BusinessButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const BusinessButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(icon),

        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}