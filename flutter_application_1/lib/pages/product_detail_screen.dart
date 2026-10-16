import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

// Helper function to format prices in Indian numbering system (e.g., ₹9,99,000)
String formatPrice(num price) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return formatter.format(price);
}

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _selectedConfigIndex = 1;

  final List<String> _colors = ['Indigo', 'Citrus', 'Silver'];
  final List<String> _sizes = ['256GB', '512GB'];
  final List<Map<String, dynamic>> _configs = [
    {
      'title': 'With Apple Care',
      'price': 75539,
      'originalPrice': 90399,
    },
    {
      'title': 'Without Apple Care',
      'price': 67990,
      'originalPrice': 79900,
    },
  ];

  void _addToCart(BuildContext context) async {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn || user.token == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }

    // Await cart update
    await context.read<CartProvider>().addToCart(
          user.token!,
          widget.product.id,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to Cart'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Store Link & Ratings
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Visit the Store',
                        style: TextStyle(
                          color: Color(0xFF007185),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.product.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star_half,
                                  color: Colors.orange, size: 16),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '(361)',
                            style: TextStyle(color: Color(0xFF007185)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.product.title,
                    style: const TextStyle(fontSize: 14, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232F3E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Choice",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3K+ bought in past month',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Product Image Section with Discount Badge
            Stack(
              children: [
                Center(
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFCC0C39),
                      shape: BoxShape.circle,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('15%',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        Text('off',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),

            // Options Section (Color Selection)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Colour: ',
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                          text: _colors[_selectedColorIndex],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colors.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedColorIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColorIndex = index),
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF007185)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: index == 0
                                      ? Colors.indigo.shade300
                                      : index == 1
                                          ? Colors.lime.shade300
                                          : Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(_colors[index],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Size Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Size: ',
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                          text: _sizes[_selectedSizeIndex],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_sizes.length, (index) {
                      final isSelected = index == _selectedSizeIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSizeIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF007185)
                                  : Colors.grey.shade400,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(_sizes[index],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Configuration Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Configuration: ',
                      style: const TextStyle(fontSize: 16),
                      children: [
                        TextSpan(
                          text: _configs[_selectedConfigIndex]['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_configs.length, (index) {
                      final isSelected = index == _selectedConfigIndex;
                      final config = _configs[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedConfigIndex = index),
                          child: Container(
                            margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF007185)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config['title']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatPrice(config['price']),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formatPrice(config['originalPrice']),
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'In stock',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),

            // Pricing & Offers Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '-15%',
                        style: TextStyle(
                            color: Color(0xFFCC0C39),
                            fontSize: 24,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatPrice(widget.product.price),
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Text(
                    'M.R.P.: ₹79,900',
                    style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'In stock',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FREE delivery Thursday, 22 October. Details',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: Colors.black87),
                      SizedBox(width: 4),
                      Text(
                        'Deliver to Location - 781017',
                        style: TextStyle(
                            color: Color(0xFF007185),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD814),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Add to Cart',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA41C),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Buy Now',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Add to Wish List',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),

            // Description / Details Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
