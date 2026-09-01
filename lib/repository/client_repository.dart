import '../models/client.dart';


class ClientRepository {


static final List<Client> clients = [

 Client(

  id: "1",

  name: "Client test",

  phone: "+2250700000000",

  whatsapp: "+2250700000000",

  address: "San Pedro",

  notes: "Cliente fidèle",

  photo: "",

  createdAt: DateTime.now(),

),

];



static void addClient(Client client){

  clients.add(client);

}


}