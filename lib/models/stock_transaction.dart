class StockTransaction {
  final int id;
  final int productId;
  final int quantity;
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as int,
      productId: json['product'] as int,
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product": productId,
      "quantity": quantity,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
