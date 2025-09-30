import 'package:flutter/material.dart';
import '../models/stock_transaction.dart';

class StockItem extends StatelessWidget {
  final StockTransaction transaction;
  final VoidCallback onDelete;

  const StockItem({
    Key? key,
    required this.transaction,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: const Icon(Icons.inventory, color: Colors.blue),
        title: Text("Product ID: ${transaction.productId}"),
        subtitle: Text(
          "Qty: ${transaction.quantity}\nDate: ${transaction.createdAt.toLocal()}",
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
