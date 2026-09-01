import 'package:flutter/material.dart';

import '../repository/client_repository.dart';
import '../repository/transaction_repository.dart';
import '../config/business_config.dart';


class DashboardPage extends StatelessWidget {

  const DashboardPage({super.key});


  @override
  Widget build(BuildContext context) {


    final clients =
        ClientRepository.clients.length;


    final transactions =
        TransactionRepository.getAll().length;


    final revenue =
        TransactionRepository.totalRevenue();



    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Tableau de bord",
        ),

        backgroundColor:
            BusinessConfig.primaryColor,

      ),



      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          children: [


            Card(

              child: ListTile(

                leading:
                const Icon(
                  Icons.people,
                  size: 40,
                ),

                title:
                const Text(
                  "Clients",
                ),

                trailing:
                Text(
                  clients.toString(),
                  style:
                  const TextStyle(
                    fontSize: 25,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

              ),

            ),



            Card(

              child: ListTile(

                leading:
                const Icon(
                  Icons.shopping_cart,
                  size: 40,
                ),

                title:
                const Text(
                  "Transactions",
                ),

                trailing:
                Text(
                  transactions.toString(),
                  style:
                  const TextStyle(
                    fontSize: 25,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

              ),

            ),




            Card(

              child: ListTile(

                leading:
                const Icon(
                  Icons.payments,
                  size: 40,
                ),

                title:
                const Text(
                  "Chiffre d'affaires",
                ),

                trailing:
                Text(
                  "${revenue.toStringAsFixed(0)} FCFA",

                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),

                ),

              ),

            ),


          ],


        ),

      ),


    );


  }


}