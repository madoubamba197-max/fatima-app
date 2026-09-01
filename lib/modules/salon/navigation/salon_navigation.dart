import 'package:flutter/material.dart';

import '../../../pages/business_home_page.dart';
import '../../../pages/catalog/catalog_page.dart';
import '../../../core/app_storage/application_manager.dart';


class SalonNavigation extends StatefulWidget {

  const SalonNavigation({
    super.key,
  });


  @override
  State<SalonNavigation> createState() =>
      _SalonNavigationState();

}


class _SalonNavigationState
    extends State<SalonNavigation> {


  int currentIndex = 0;



  @override
  Widget build(BuildContext context) {


    final commerce =
        ApplicationManager.getCurrentApplication();



    if (commerce == null) {

      return const Scaffold(

        body: Center(

          child: Text(
            "Aucun commerce sélectionné",
          ),

        ),

      );

    }



    final List<Widget> pages = [


      const BusinessHomePage(),



      CatalogPage(
  commerceId:
      ApplicationManager
          .getCurrentApplication()!
          .commerceId,
),


      const Center(

        child: Text(

          "Rendez-vous",

          style: TextStyle(
            fontSize: 22,
          ),

        ),

      ),



      const Center(

        child: Text(

          "Clients",

          style: TextStyle(
            fontSize: 22,
          ),

        ),

      ),


    ];



    return Scaffold(


      body: pages[currentIndex],



      bottomNavigationBar:
          BottomNavigationBar(


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

            label: "RDV",

          ),



          BottomNavigationBarItem(

            icon: Icon(Icons.people),

            label: "Clients",

          ),


        ],


      ),


    );


  }


}