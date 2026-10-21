import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/constants/api_config.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/providers/wishlist_provider.dart';

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
  int _selectedVariantIndex = 0;
  List<Map<String, dynamic>> _attributeDefs = [];
  bool _loadingDefs = false;

  @override
  void initState() {
    super.initState();
    _fetchAttributeDefinitions();
  }

  Future<void> _fetchAttributeDefinitions() async {
    if (widget.product.category.isEmpty) return;
    setState(() => _loadingDefs = true);
    try {
      final category = Uri.encodeComponent(widget.product.category);
      final res = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/v1/categories/$category/attributes'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List defs = data['definitions'] ?? [];
        if (mounted) {
          setState(() {
            _attributeDefs = List<Map<String, dynamic>>.from(defs);
            _loadingDefs = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDefs = false);
    }
  }

  void _addToCart(BuildContext context) async {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn || user.token == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }

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

  Widget _buildSpecTable() {
    if (_loadingDefs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attributeDefs.isEmpty || widget.product.attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> rows = [];

    for (final def in _attributeDefs) {
      final key = def['key'];
      final label = def['label'] ?? key;
      final unit = def['unit']?.toString() ?? '';

      if (widget.product.attributes.containsKey(key)) {
        final val = widget.product.attributes[key];
        String displayValue = '$val';

        if (val is bool) {
          displayValue = val ? 'Yes' : 'No';
        } else if (unit.isNotEmpty) {
          displayValue = '$val $unit';
        }

        rows.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: rows.length % 2 == 0 ? Colors.grey.shade100 : Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    displayValue,
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            'Product Specifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: rows),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDynamicVariantSelector() {
    final attrs = widget.product.attributes;
    if (attrs.isEmpty) return const SizedBox.shrink();

    // Determine variant highlight key dynamically based on category attributes
    String? variantKey;
    String? label;

    if (attrs.containsKey('storage')) {
      variantKey = 'storage';
      label = 'Storage';
    } else if (attrs.containsKey('capacity')) {
      variantKey = 'capacity';
      label = 'Capacity';
    } else if (attrs.containsKey('sizeUK')) {
      variantKey = 'sizeUK';
      label = 'UK Size';
    } else if (attrs.containsKey('volume')) {
      variantKey = 'volume';
      label = 'Volume';
    } else if (attrs.containsKey('ram')) {
      variantKey = 'ram';
      label = 'RAM';
    }

    if (variantKey == null) return const SizedBox.shrink();

    // Extract definition unit if present
    final def = _attributeDefs.firstWhere(
      (d) => d['key'] == variantKey,
      orElse: () => {},
    );
    final unit = def['unit']?.toString() ?? '';
    final currentValue = attrs[variantKey];
    final displayVal =
        unit.isNotEmpty ? '$currentValue $unit' : '$currentValue';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: displayVal,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedVariantIndex = 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedVariantIndex == 0
                          ? const Color(0xFF007185)
                          : Colors.grey.shade400,
                      width: _selectedVariantIndex == 0 ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    displayVal,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();
    final isWishlisted = wishlistProvider.isWishlisted(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  if (widget.product.isSponsored)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
              ],
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),
            _buildDynamicVariantSelector(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formatPrice(widget.product.price),
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.stock > 0 ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                        color: widget.product.stock > 0
                            ? Colors.green
                            : Colors.red,
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
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final user = context.read<UserProvider>();
                        if (!user.isLoggedIn || user.token == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AuthScreen()),
                          );
                          return;
                        }
                        context
                            .read<WishlistProvider>()
                            .toggleWishlist(user.token!, widget.product.id);
                      },
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black,
                        size: 18,
                      ),
                      label: Text(
                        isWishlisted ? 'In Your Wish List' : 'Add to Wish List',
                        style: const TextStyle(color: Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.black12),
            _buildSpecTable(),
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
