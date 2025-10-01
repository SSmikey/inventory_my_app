import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';

// ใช้ธีมสีเดียวกับ Login/Dashboard
class AppColors {
  static const primaryOrange = Color(0xFFFFAA80); // Soft Coral
  static const secondaryOrange = Color(0xFFFFCC99); // Warm Peach
  static const accentOrange = Color(0xFFFF8C66); // Muted Orange
  static const backgroundStart = Color(0xFFFFF5EB); // Cream White
  static const backgroundEnd = Color(0xFFFFE4CC); // Light Peach
  static const cardBackground = Color(0xFFFFFAF5); // Off White
  static const textDark = Color(0xFF5A4A42); // Warm Brown
}

class ProductScreen extends StatefulWidget {
  final String token;
  final VoidCallback? reloadCallback;

  const ProductScreen({Key? key, required this.token, this.reloadCallback})
    : super(key: key);

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
      if (!mounted) return;

      setState(() {
        _products = data
            .map(
              (e) => Product(
                id: int.tryParse(e['id'].toString()) ?? 0,
                name: e['name'].toString(),
                price: double.tryParse(e['price'].toString()) ?? 0.0,
              ),
            )
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading products: $e"),
          backgroundColor: AppColors.accentOrange,
        ),
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
      if (!mounted) return;

      nameController.clear();
      priceController.clear();
      await _loadProducts();
      widget.reloadCallback?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding product: $e"),
          backgroundColor: AppColors.accentOrange,
        ),
      );
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _service.deleteProduct(widget.token, id);
      if (!mounted) return;

      await _loadProducts();
      widget.reloadCallback?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting product: $e"),
          backgroundColor: AppColors.accentOrange,
        ),
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final editNameController = TextEditingController(text: product.name);
    final editPriceController = TextEditingController(
      text: product.price.toString(),
    );

    if (!mounted) return;

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            onPressed: () async {
              try {
                await _service.updateProduct(widget.token, product.id, {
                  "name": editNameController.text,
                  "price": double.parse(editPriceController.text),
                });
                if (!mounted) return;
                Navigator.pop(context);
                await _loadProducts();
                widget.reloadCallback?.call();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error updating product: $e"),
                    backgroundColor: AppColors.accentOrange,
                  ),
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
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: AppColors.primaryOrange,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Product Name",
                labelStyle: const TextStyle(color: AppColors.textDark),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.accentOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: const TextStyle(color: AppColors.textDark),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.accentOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // เปลี่ยนเป็นสีขาว
                foregroundColor:
                    AppColors.textDark, // เปลี่ยนตัวอักษรเป็นสีเข้ม
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Add Product"),
            ),

            const SizedBox(height: 24),
            const Text(
              "Product List",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductItem(
                    product: product,
                    onDelete: () => _deleteProduct(product.id),
                    onEdit: () => _editProduct(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
