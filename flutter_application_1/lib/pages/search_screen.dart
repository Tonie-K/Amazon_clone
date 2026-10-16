import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/constants/intl.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';
import 'package:flutter_application_1/pages/filter_screen.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
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
  List<String> _selectedFilters = [];

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

  void _navigateToFilterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          searchQuery: widget.searchQuery,
          initialIsPrime: _isPrimeOnly,
          initialSelectedFilters: _selectedFilters,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _isPrimeOnly = result['isPrime'] ?? false;
        _selectedFilters = List<String>.from(result['selectedFilters'] ?? []);
      });
    }
  }

  void _addToCart(BuildContext context, Product product) async {
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
          product.id,
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

  int? _extractStorageGB(Product product) {
    final combinedText =
        '${product.title} ${product.specBadge ?? ''}'.toUpperCase();

    final match = RegExp(r'(\d+)\s*(GB|TB)').firstMatch(combinedText);
    if (match != null) {
      final value = int.parse(match.group(1)!);
      final unit = match.group(2)!;
      return unit == 'TB' ? value * 1024 : value;
    }
    return null;
  }

  bool _matchesStorageChip(int? capacityGB, String chip) {
    if (capacityGB == null) return false;
    if (chip == '250 - 499 GB') {
      return capacityGB >= 250 && capacityGB <= 499;
    } else if (chip == '500 - 999 GB') {
      return capacityGB >= 500 && capacityGB <= 999;
    } else if (chip == '1 TB & above') {
      return capacityGB >= 1000;
    }
    return false;
  }

  bool _matchesWholeWord(Product product, String targetWord) {
    final combinedText =
        '${product.title} ${product.specBadge ?? ''} ${product.description}';
    final pattern =
        RegExp('\\b${RegExp.escape(targetWord)}\\b', caseSensitive: false);
    return pattern.hasMatch(combinedText);
  }

  List<Product> _applyFilters(List<Product> initialList) {
    List<Product> products = List.from(initialList);

    if (_isPrimeOnly) {
      products = products.where((p) => p.isSponsored).toList();
    }

    if (_selectedFilters.isEmpty) {
      return products;
    }

    final Map<String, List<String>> filterGroups = {
      'rating': [],
      'storage': [],
      'brands': [],
      'specs': [],
      'other': [],
    };

    for (final filter in _selectedFilters) {
      if (filter == '4★ & Up') {
        filterGroups['rating']!.add(filter);
      } else if (filter == '250 - 499 GB' ||
          filter == '500 - 999 GB' ||
          filter == '1 TB & above') {
        filterGroups['storage']!.add(filter);
      } else if ([
        'HP',
        'Lenovo',
        'Dell',
        'ASUS',
        'Acer',
        'MSI',
        'Milton',
        'Cello'
      ].contains(filter)) {
        filterGroups['brands']!.add(filter);
      } else if ([
        'Intel',
        'AMD',
        'NVIDIA',
        'SSD',
        'Stainless Steel',
        'Insulated',
        'BPA Free',
        'Copper'
      ].contains(filter)) {
        filterGroups['specs']!.add(filter);
      } else {
        filterGroups['other']!.add(filter);
      }
    }

    return products.where((product) {
      if (filterGroups['rating']!.isNotEmpty) {
        if (product.rating < 4.0) return false;
      }

      if (filterGroups['storage']!.isNotEmpty) {
        final capacityGB = _extractStorageGB(product);
        final storageMatch = filterGroups['storage']!
            .any((chip) => _matchesStorageChip(capacityGB, chip));
        if (!storageMatch) return false;
      }

      if (filterGroups['brands']!.isNotEmpty) {
        final brandMatch = filterGroups['brands']!
            .any((brand) => _matchesWholeWord(product, brand));
        if (!brandMatch) return false;
      }

      if (filterGroups['specs']!.isNotEmpty) {
        final specMatch = filterGroups['specs']!
            .any((spec) => _matchesWholeWord(product, spec));
        if (!specMatch) return false;
      }

      if (filterGroups['other']!.isNotEmpty) {
        final otherMatch = filterGroups['other']!
            .any((other) => _matchesWholeWord(product, other));
        if (!otherMatch) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
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
                    backgroundColor: const Color(0xFF007185),
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: _navigateToFilterScreen,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      side: BorderSide(
                        color: (_selectedFilters.isNotEmpty || _isPrimeOnly)
                            ? const Color(0xFF007185)
                            : const Color(0xFF888C8C),
                        width: (_selectedFilters.isNotEmpty || _isPrimeOnly)
                            ? 1.5
                            : 1,
                      ),
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
                          const Icon(
                            Icons.check,
                            size: 15,
                            color: Color(0xFF00A8E1),
                          ),
                          const SizedBox(width: 2),
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
                  if (_selectedFilters.isNotEmpty)
                    ..._selectedFilters.map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFilterChip(
                          filter,
                          isSelected: true,
                          onTap: () {
                            setState(() {
                              _selectedFilters.remove(filter);
                            });
                          },
                        ),
                      ),
                    )
                  else ...[
                    _buildFilterChip('Great Indian Festival'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Get It in 2 Days'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Eligible for Pay on Delivery'),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE3E6E6)),
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

                final products = _applyFilters(snapshot.data!);

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products match the selected filters.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  );
                }

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
                            SizedBox(
                              width: 140,
                              child: Container(
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
                                      child: InkWell(
                                        onTap: () =>
                                            _addToCart(context, product),
                                        borderRadius: BorderRadius.circular(20),
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                      onPressed: () =>
                                          _addToCart(context, product),
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

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2F3F5) : Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF007185) : const Color(0xFF888C8C),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF0F1111),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 14, color: Color(0xFF007185)),
            ],
          ],
        ),
      ),
    );
  }
}
