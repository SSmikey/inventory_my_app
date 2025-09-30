import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String token = ""; // 👉 ต้องใส่ token หลังจาก login

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _service.fetchProducts(token);
      setState(() {
        _products = data.map((e) => Product.fromJson(e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;
    try {
      await _service.addProduct(token, {
        "name": nameController.text,
        "price": double.parse(priceController.text),
      });
      _loadProducts();
      nameController.clear();
      priceController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _service.deleteProduct(token, id);
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting product")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text("Add Product"),
            ),
            const SizedBox(height: 24),
            const Text("Product List", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductItem(
                    product: product,
                    onDelete: () => _deleteProduct(product.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
