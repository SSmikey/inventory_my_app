import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/product_service.dart';
import '../providers/auth_provider.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLoading = true;
  List<dynamic> _products = [];
  final ProductService _service = ProductService();

  void _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).accessToken!;
      final products = await _service.fetchProducts(token);
      setState(() => _products = products);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProductDialog({Map<String, dynamic>? product}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(text: product?['price']?.toString() ?? '');
    final quantityController = TextEditingController(text: product?['quantity']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? "Add Product" : "Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final token = Provider.of<AuthProvider>(context, listen: false).accessToken!;
              final data = {
                "name": nameController.text,
                "price": double.tryParse(priceController.text) ?? 0,
                "quantity": int.tryParse(quantityController.text) ?? 0,
              };

              try {
                if (product == null) {
                  await _service.addProduct(token, data);
                } else {
                  await _service.updateProduct(token, product['id'], data);
                }
                _loadProducts();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int id) async {
    final token = Provider.of<AuthProvider>(context, listen: false).accessToken!;
    try {
      await _service.deleteProduct(token, id);
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (_, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text("Price: \$${product['price']} | Quantity: ${product['quantity']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => _showProductDialog(product: product)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteProduct(product['id'])),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showProductDialog(),
      ),
    );
  }
}
