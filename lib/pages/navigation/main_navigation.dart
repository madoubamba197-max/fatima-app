import 'package:flutter/material.dart';

import '../business_home_page.dart';
import '../../core/module_loader.dart';
import '../catalog/catalog_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  final pages = [

  ModuleLoader.getHomePage(),

    const CatalogPage(),

    const Center(
      child: Text(
        "Réservations",
        style: TextStyle(fontSize: 22),
      ),
    ),

    const Center(
      child: Text(
        "Clients",
        style: TextStyle(fontSize: 22),
      ),
    ),

    const Center(
      child: Text(
        "Paramètres",
        style: TextStyle(fontSize: 22),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {

          setState(() {

            currentIndex = index;

          });

        },

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Accueil",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Catalogue",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Réservation",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Clients",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Paramètres",
          ),
        ],
      ),
    );
  }
}