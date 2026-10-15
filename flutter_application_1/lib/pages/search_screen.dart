import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/constants/intl.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/services/product_service.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search-screen';
  final String searchQuery;

  const SearchScreen({super.key, required this.searchQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<Product>> _searchFuture;
  bool _isPrimeOnly = false;

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
      body: Column(
        children: [
          // 1. Delivery Location & "Join Prime" Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: GlobalVariables.secondaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 22,
                      color: Color(0xFF0F1111),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Deliver to 781017',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F1111),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xFF0F1111),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007185), // Amazon blue
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Join Prime',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Horizontal Filter Bar (Filter Icon + Prime Switch + Filter Chips)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter Icon Button
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      side: const BorderSide(color: Color(0xFF888C8C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_outlined,
                      size: 20,
                      color: Color(0xFF0F1111),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Prime Filter Toggle Chip
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPrimeOnly = !_isPrimeOnly;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _isPrimeOnly
                              ? const Color(0xFF007185)
                              : const Color(0xFFD5D9D9),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Checkmark Icon
                          const Icon(
                            Icons.check,
                            size: 15,
                            color: Color(0xFF00A8E1),
                          ),
                          const SizedBox(width: 2),
                          // Prime Text
                          const Text(
                            'prime',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF00A8E1),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Compact Custom Toggle Switch
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 34,
                            height: 18,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _isPrimeOnly
                                  ? const Color(0xFF007185)
                                  : const Color(0xFF888C8C),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              alignment: _isPrimeOnly
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filter Chip 1: Great Indian Festival
                  _buildFilterChip('Great Indian Festival'),
                  const SizedBox(width: 8),

                  // Filter Chip 2: Get It in 2 Days
                  _buildFilterChip('Get It in 2 Days'),
                  const SizedBox(width: 8),

                  // Filter Chip 3: Eligible for Pay on Delivery
                  _buildFilterChip('Eligible for Pay on Delivery'),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE3E6E6)),

          // 3. Search Results List
          Expanded(
            child: FutureBuilder<List<Product>>(
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Section: Product Image & Cart Badge
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
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
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

                            // Right Section: Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
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

                                  SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFD814),
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
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
          ),
        ],
      ),
    );
  }

  // Helper widget to render custom rounded filter pills
  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF888C8C)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F1111),
        ),
      ),
    );
  }
}
