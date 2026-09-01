import 'package:flutter/material.dart';

import '../pages/restaurant_home_page.dart';

class RestaurantNavigation extends StatefulWidget {
  const RestaurantNavigation({super.key});

  @override
  State<RestaurantNavigation> createState() =>
      _RestaurantNavigationState();
}

class _RestaurantNavigationState
    extends State<RestaurantNavigation> {

  int currentIndex = 0;

  final List<Widget> pages = [

    const RestaurantHomePage(),

    const Center(
      child: Text(
        "Menu",
        style: TextStyle(fontSize: 22),
      ),
    ),

    const Center(
      child: Text(
        "Panier",
        style: TextStyle(fontSize: 22),
      ),
    ),

    const Center(
      child: Text(
        "Profil",
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
            icon: Icon(Icons.restaurant_menu),
            label: "Menu",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Panier",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),

        ],

      ),

    );

  }

}