import '../models/transaction.dart';


class TransactionRepository {


  static final List<Transaction> transactions = [];



  static void addTransaction(
      Transaction transaction
  ){

    transactions.add(transaction);

  }



  static List<Transaction> getAll(){

    return transactions;

  }



  static double totalRevenue(){

    double total = 0;


    for(final t in transactions){

      if(t.status == "Payé"){

        total += t.amount;

      }

    }


    return total;

  }


}