import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';
import 'dart:ui';

// ใช้ธีมสีเดียวกับ Login/Dashboard
class AppColors {
  static const primaryOrange = Color(0xFFFFAA80);
  static const secondaryOrange = Color(0xFFFFCC99);
  static const accentOrange = Color(0xFFFF8C66);
  static const backgroundStart = Color(0xFFFFF5EB);
  static const backgroundEnd = Color(0xFFFFE4CC);
  static const textDark = Color(0xFF5A4A42);
  static const shadowColor = Color(0x1AFF8C66);
}

class ProductScreen extends StatefulWidget {
  final String token;
  final VoidCallback? reloadCallback;

  const ProductScreen({Key? key, required this.token, this.reloadCallback})
    : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  final ProductService _service = ProductService();
  List<Product> _products = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    priceController.dispose();
    super.dispose();
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
      _animationController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error loading products: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.accentOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      _showSnackBar("กรุณากรอกชื่อสินค้าและราคา", isError: true);
      return;
    }
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
      _showSnackBar("เพิ่มสินค้าสำเร็จ");
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error adding product: $e", isError: true);
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      await _service.deleteProduct(widget.token, id);
      if (!mounted) return;

      await _loadProducts();
      widget.reloadCallback?.call();
      _showSnackBar("ลบสินค้าสำเร็จ");
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error deleting product: $e", isError: true);
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.accentOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Edit Product",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDialogTextField(
                    controller: editNameController,
                    label: "Product Name",
                    icon: Icons.shopping_bag_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: editPriceController,
                    label: "Price",
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.accentOrange,
                                AppColors.primaryOrange,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentOrange.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                try {
                                  await _service
                                      .updateProduct(widget.token, product.id, {
                                        "name": editNameController.text,
                                        "price": double.parse(
                                          editPriceController.text,
                                        ),
                                      });
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  await _loadProducts();
                                  widget.reloadCallback?.call();
                                  _showSnackBar("แก้ไขสินค้าสำเร็จ");
                                } catch (e) {
                                  if (!mounted) return;
                                  _showSnackBar(
                                    "Error updating product: $e",
                                    isError: true,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundStart,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textDark.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppColors.accentOrange, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "เพิ่มสินค้าใหม่",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildGlassTextField(
                            controller: nameController,
                            label: "ชื่อสินค้า",
                            icon: Icons.shopping_bag_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildGlassTextField(
                            controller: priceController,
                            label: "ราคา",
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.accentOrange,
                                  AppColors.primaryOrange,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentOrange.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _addProduct,
                                borderRadius: BorderRadius.circular(14),
                                child: const Center(
                                  child: Text(
                                    "เพิ่มสินค้า",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "รายการสินค้า",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 80,
                                  color: AppColors.textDark.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "ยังไม่มีสินค้า",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textDark.withOpacity(0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textDark.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppColors.accentOrange, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
