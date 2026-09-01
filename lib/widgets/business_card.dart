import 'package:flutter/material.dart';

class BusinessCard extends StatelessWidget {
  final Widget child;

  const BusinessCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}