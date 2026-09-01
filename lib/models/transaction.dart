class Transaction {

  final String id;

  final String clientId;

  final String clientName;

  final String itemName;

  final double amount;

  final DateTime date;

  final String type;

  String status;


  Transaction({

    required this.id,

    required this.clientId,

    required this.clientName,

    required this.itemName,

    required this.amount,

    required this.date,

    required this.type,

    this.status = "En attente",

  });



  Map<String, dynamic> toMap(){

    return {

      "id": id,

      "clientId": clientId,

      "clientName": clientName,

      "itemName": itemName,

      "amount": amount,

      "date": date.toIso8601String(),

      "type": type,

      "status": status,

    };

  }



  factory Transaction.fromMap(Map<String,dynamic> map){

    return Transaction(

      id: map["id"] ?? "",

      clientId: map["clientId"] ?? "",

      clientName: map["clientName"] ?? "",

      itemName: map["itemName"] ?? "",

      amount: (map["amount"] ?? 0).toDouble(),

      date: DateTime.parse(

        map["date"],

      ),

      type: map["type"] ?? "",

      status: map["status"] ?? "En attente",

    );

  }

}