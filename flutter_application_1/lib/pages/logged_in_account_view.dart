import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:flutter_application_1/constants/api_config.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/models/product_filters.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/pages/wishlist_page.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/services/product_service.dart';

class LoggedInAccountView extends StatefulWidget {
  const LoggedInAccountView({super.key});

  @override
  State<LoggedInAccountView> createState() => _LoggedInAccountViewState();
}

class _LoggedInAccountViewState extends State<LoggedInAccountView> {
  List<Product> _ordersProducts = [];
  List<Product> _buyAgainProducts = [];
  List<Product> _recommendedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn || user.token == null) return;

    try {
      // 1. Fetch real orders from backend
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/get/orders'),
        headers: {'authorization': user.token!},
      );

      final List<Product> orders = [];
      final Set<String> seenIds = {};

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List ordersList = data['response'] ?? [];

        for (final order in ordersList) {
          final List items = order['products'] ?? [];
          for (final item in items) {
            if (item['product'] != null && item['product'] is Map) {
              final prod = Product.fromJson(item['product']);
              orders.add(prod);
            }
          }
        }
      }

      //Buy Again
      final List<Product> buyAgain = [];
      for (final p in orders) {
        if (seenIds.add(p.id)) {
          buyAgain.add(p);
        }
      }

      // 2. Fetch recommendations from ProductService
      final searchResult = await ProductService.searchProducts(
        query: orders.isNotEmpty ? orders.last.category : '',
        limit: 6,
        filters: ProductFilters(),
      );

      if (mounted) {
        setState(() {
          _ordersProducts = orders;
          _buyAgainProducts = buyAgain;
          _recommendedProducts = searchResult.products;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return RefreshIndicator(
      color: const Color(0xFF007185),
      onRefresh: _fetchUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header ----------
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFB0BEC5),
                    child: Icon(Icons.person_outline,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Hello, ${user.displayName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 17, color: Color(0xFF0F1111)),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 22),
                      ],
                    ),
                  ),
                  const Icon(Icons.settings_outlined,
                      color: Color(0xFF0F1111), size: 26),
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_none,
                      color: Color(0xFF0F1111), size: 26),
                ],
              ),
            ),

            // ---------- Quick Pills ----------
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _PillButton(label: 'Orders', onTap: () {}),
                  _PillButton(label: 'Buy Again', onTap: () {}),
                  _PillButton(label: 'Account', onTap: () {}),
                  _PillButton(
                    label: 'Lists',
                    onTap: () =>
                        Navigator.pushNamed(context, WishlistPage.routeName),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
              // ---------- Your Orders ----------
              _SectionHeader(title: 'Your Orders', onTap: () {}),
              _ProductListHorizontal(
                  products: _ordersProducts, height: 140, width: 140),
              const SizedBox(height: 24),

              // ---------- Buy Again ----------
              _SectionHeader(title: 'Buy Again', onTap: () {}),
              _ProductListHorizontal(
                  products: _buyAgainProducts, height: 120, width: 120),
              const SizedBox(height: 24),

              // ---------- Keep Shopping For ----------
              _SectionHeader(title: 'Keep shopping for', onTap: () {}),
              _ProductListHorizontal(
                products: _recommendedProducts,
                height: 140,
                width: 140,
                showLabel: true,
              ),
              const SizedBox(height: 24),
            ],

            // ---------- Wish list + Sign out ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.favorite_border,
                        color: Colors.black87),
                    title: const Text('Your Wish List'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, WishlistPage.routeName),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => context.read<UserProvider>().logout(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: GlobalVariables.greyBackgroundCOlor,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFD5D9D9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= Helper Widgets =======================

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F1111),
          side: const BorderSide(color: Color(0xFF888C8C)),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F1111),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: const Icon(Icons.arrow_forward, size: 24),
          ),
        ],
      ),
    );
  }
}

class _ProductListHorizontal extends StatelessWidget {
  final List<Product> products;
  final double height;
  final double width;
  final bool showLabel;

  const _ProductListHorizontal({
    required this.products,
    required this.height,
    required this.width,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No items yet', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: height + (showLabel ? 28 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                ProductDetailScreen.routeName,
                arguments: p,
              );
            },
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: height,
                    width: width,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD5D9D9)),
                    ),
                    child: Image.network(
                      p.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 6),
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
