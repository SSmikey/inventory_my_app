import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';

class ProductScreen extends StatefulWidget {
  final String token;
  final VoidCallback? reloadCallback; // callback สำหรับรีโหลด dashboard

  const ProductScreen({Key? key, required this.token, this.reloadCallback}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _service.fetchProducts(widget.token);
      setState(() {
        _products = data.map((e) => Product(
          id: int.tryParse(e['id'].toString()) ?? 0,
          name: e['name'].toString(),
          price: double.tryParse(e['price'].toString()) ?? 0.0,
        )).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading products: $e")),
      );
    }
  }

  Future<void> _addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;
    try {
      await _service.addProduct(widget.token, {
        "name": nameController.text,
        "price": double.parse(priceController.text),
      });
      nameController.clear();
      priceController.clear();
      await _loadProducts(); // รีโหลดข้อมูล
      widget.reloadCallback?.call(); // รีโหลด dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding product: $e")),
      );
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _service.deleteProduct(widget.token, id);
      await _loadProducts(); // รีโหลดข้อมูลหลังลบ
      widget.reloadCallback?.call(); // รีโหลด dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting product: $e")),
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final editNameController = TextEditingController(text: product.name);
    final editPriceController = TextEditingController(text: product.price.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editNameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: editPriceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.updateProduct(widget.token, product.id, {
                  "name": editNameController.text,
                  "price": double.parse(editPriceController.text),
                });
                Navigator.pop(context);
                await _loadProducts();
                widget.reloadCallback?.call(); // รีโหลด dashboard
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error updating product: $e")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
                    onEdit: () => _editProduct(product), // เพิ่ม callback edit
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
