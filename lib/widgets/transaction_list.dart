import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import 'package:flutter/material.dart';
import './transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  Function deleteTransaction;

  TransactionList(this.transactions, this.deleteTransaction);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return transactions.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: [
                  Text(
                    'No transactions added yet!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: constraints.maxHeight * 0.6,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              );
            },
          )
        : /* ListView.builder(
            itemBuilder: (ctx, index) {
              var container = Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                child: TransactionItem(
                    transaction: transactions[index],
                    deleteTransaction: deleteTransaction),
              );
              return container;
            },
            itemCount: transactions.length,
          )*/
        ListView(
            children: transactions
                .map(
                  (trx) => TransactionItem(
                    key: ValueKey(trx.id),
                    transaction: trx,
                    deleteTransaction: deleteTransaction,
                  ),
                )
                .toList(),
          );
  }
}
