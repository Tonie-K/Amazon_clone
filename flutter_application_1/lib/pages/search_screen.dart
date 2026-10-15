import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/constants/intl.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search-screen';
  final String searchQuery;

  const SearchScreen({super.key, required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<Product>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = ProductService.searchProducts(widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      setState(() {
        _searchFuture = ProductService.searchProducts(widget.searchQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: FutureBuilder<List<Product>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No results found for "${widget.searchQuery}"',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];

              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ProductDetailScreen.routeName,
                    arguments: product,
                  );
                },
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Section: Product Image & Floating Icon
                      SizedBox(
                        width: 140,
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.contain,
                                    height: 130,
                                    width: 130,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Positioned(
                                    left: 6,
                                    bottom: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFE3E6E6),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart_outlined,
                                        size: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Right Section: Product Details & Actions
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sponsored Tag (Only shown if isSponsored == true)
                            if (product.isSponsored) ...[
                              const Text(
                                'Sponsored',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF565959),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],

                            // Product Title
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0F1111),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Dynamic Spec Badge (Only shown if product has specBadge populated)
                            if (product.specBadge != null &&
                                product.specBadge!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F2F2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.specBadge!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF0F1111),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],

                            // Ratings & Purchased Info
                            Row(
                              children: [
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < product.rating.floor()
                                          ? Icons.star
                                          : Icons.star_half,
                                      color: const Color(0xFFDE7921),
                                      size: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '(148)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF007185),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '1K+ bought in past month',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF565959),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Price Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, -7),
                                  child: const Text(
                                    '₹',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F1111),
                                    ),
                                  ),
                                ),
                                Text(
                                  NumberFormatters.formatIndianCurrency(
                                      product.price),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F1111),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Bank Offer Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7CB667),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                'Buy for ₹${(product.price * 0.9).toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'FREE delivery Sat, 17 Oct',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0F1111),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Yellow Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Connect cart service logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD814),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Add to cart',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
