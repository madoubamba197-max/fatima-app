import 'package:flutter/material.dart';

class SalonHomePage extends StatelessWidget {
  const SalonHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Accueil Salon",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}