import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_search_bar.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/product_service.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: GlobalVariables.secondaryColor,
            child: const SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(height: 8),
                  _QuickLinks(),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 4, 4),
                    child: CustomSearchBar(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                SizedBox(height: 12),
                _DeliveryBar(),
                SizedBox(height: 12),
                _HeroRow(),
                SizedBox(height: 12),
                _FeatureCards(),
                SizedBox(height: 16),
                _ThumbGrid(),
                SizedBox(height: 20),
                _SectionHeader(
                  title: 'Brands related to your search',
                  sponsored: true,
                ),
                SizedBox(height: 12),
                _BrandCards(),
                SizedBox(height: 24),
                _SectionHeader(title: 'Recommended deals for you'),
                SizedBox(height: 12),
                _DealsRow(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String? asset;
  final double? width;
  final double? height;
  final double radius;
  final Color color;
  final Color iconColor;
  final IconData icon;

  const _ImageBox({
    this.asset,
    this.width,
    this.height,
    this.radius = 12,
    this.color = const Color(0xFFE3E6E6),
    this.iconColor = Colors.black38,
    this.icon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: asset != null
            ? Image.asset(asset!, fit: BoxFit.cover)
            : ColoredBox(
                color: color,
                child: Center(child: Icon(icon, size: 32, color: iconColor)),
              ),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(child: _QuickLinkItem(icon: Icons.smartphone, label: 'Pay')),
          Expanded(
              child: _QuickLinkItem(icon: Icons.checkroom, label: 'Bazaar')),
          Expanded(
              child: _QuickLinkItem(icon: Icons.devices, label: 'Deals Live')),
          Expanded(
              child: _QuickLinkItem(
                  icon: Icons.local_offer_outlined, label: 'Video')),
          Expanded(
              child: _QuickLinkItem(
                  icon: Icons.grid_view_rounded, label: 'Pharmacy')),
        ],
      ),
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickLinkItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE3E6E6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 30, color: const Color(0xFF333333)),
      ),
    );
  }
}

class _DeliveryBar extends StatelessWidget {
  const _DeliveryBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: GlobalVariables.greyBackgroundCOlor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 20),
                  SizedBox(width: 8),
                  // Placeholder pincode; later this can come from the user's saved address
                  Text(
                    'Deliver to 781017',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow();

  static const _colors = [
    Color(0xFF3B4A6B),
    Color(0xFF2F2F2F),
    Color(0xFF6B4F3A),
  ];
  static const _icons = [Icons.checkroom, Icons.keyboard, Icons.watch];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _ImageBox(
          width: 300,
          height: 320,
          radius: 16,
          color: _colors[i],
          iconColor: Colors.white70,
          icon: _icons[i],
        ),
      ),
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  static const _icons = [
    Icons.tablet_mac,
    Icons.keyboard_alt_outlined,
    Icons.headphones,
    Icons.watch_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _icons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _ImageBox(
          width: 160,
          height: 150,
          radius: 14,
          icon: _icons[i],
        ),
      ),
    );
  }
}

class _ThumbGrid extends StatelessWidget {
  const _ThumbGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(12, (_) => const _ImageBox(radius: 8)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool sponsored;
  const _SectionHeader({required this.title, this.sponsored = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          if (sponsored)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    'Sponsored',
                    style: TextStyle(fontSize: 12, color: Color(0xFF565959)),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.info, size: 14, color: Colors.grey),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandCards extends StatelessWidget {
  const _BrandCards();

  static const _names = ['Mac', 'Mi', 'Samsung'];
  static const _icons = [Icons.laptop_mac, Icons.smartphone, Icons.tv];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(
          width: 280,
          child: Column(
            children: [
              Expanded(
                child: _ImageBox(
                  width: double.infinity,
                  radius: 12,
                  icon: _icons[i],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _names[i],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealsRow extends StatefulWidget {
  const _DealsRow();

  @override
  State<_DealsRow> createState() => _DealsRowState();
}

class _DealsRowState extends State<_DealsRow> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 230,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No products available')),
          );
        }

        final products = snapshot.data!;

        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ProductDetailScreen.routeName,
                    arguments: product,
                  );
                },
                child: SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 150,
                            height: 150,
                            color: const Color(0xFFE3E6E6),
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
