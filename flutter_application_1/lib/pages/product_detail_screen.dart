import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product-details';
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                color: Color(0xFFB12704),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  product.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add to Cart',
              onTap: () {
                // TODO: Wire up cart integration
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Buy Now',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
