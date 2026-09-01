import 'package:flutter/material.dart';

import '../models/client.dart';
import '../repository/client_repository.dart';


class AddClientPage extends StatefulWidget {

  const AddClientPage({super.key});


  @override
  State<AddClientPage> createState() => _AddClientPageState();

}



class _AddClientPageState extends State<AddClientPage> {


final nomController = TextEditingController();

final phoneController = TextEditingController();



void enregistrerClient(){


if(nomController.text.isEmpty ||
   phoneController.text.isEmpty){

  ScaffoldMessenger.of(context).showSnackBar(

    const SnackBar(

      content: Text(
        "Veuillez remplir le nom et le téléphone",
      ),

    ),

  );

  return;

}



final client = Client(

  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),

  name: nomController.text,

  phone: phoneController.text,

  whatsapp: phoneController.text,

  address: "",

  notes: "",

  photo: "",

  createdAt: DateTime.now(),

);



ClientRepository.addClient(client);



Navigator.pop(context);



}



@override
void dispose(){

nomController.dispose();

phoneController.dispose();


super.dispose();

}



@override
Widget build(BuildContext context){


return Scaffold(


appBar: AppBar(

title: const Text(
  "Nouveau client",
),

),



body: Padding(

padding: const EdgeInsets.all(20),


child: Column(


children: [



TextField(

controller: nomController,

decoration: const InputDecoration(

labelText: "Nom du client",

border: OutlineInputBorder(),

),

),



const SizedBox(height:15),



TextField(

controller: phoneController,

keyboardType: TextInputType.phone,

decoration: const InputDecoration(

labelText: "Téléphone",

border: OutlineInputBorder(),

),

),



const SizedBox(height:15),




const SizedBox(height:30),



SizedBox(

width: double.infinity,


child: ElevatedButton(


onPressed: enregistrerClient,


child: const Text(
"Enregistrer",
),


),


),


],


),


),


);


}


}