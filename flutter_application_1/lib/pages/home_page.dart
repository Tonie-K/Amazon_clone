import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_search_bar.dart';
import 'package:flutter_application_1/constants/intl.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/pages/search_screen.dart';
import 'package:flutter_application_1/services/product_service.dart';

void _openProduct(BuildContext context, Product product) {
  Navigator.pushNamed(
    context,
    ProductDetailScreen.routeName,
    arguments: product,
  );
}

void _openSearch(BuildContext context, String query) {
  Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
}

String _price(double price) =>
    '₹${NumberFormatters.formatIndianCurrency(price)}';

List<String> _categoriesOf(List<Product> products) {
  final seen = <String>[];
  for (final p in products) {
    if (p.category.isNotEmpty && !seen.contains(p.category)) {
      seen.add(p.category);
    }
  }
  return seen;
}

List<Product> _topRated(List<Product> products) {
  final sorted = [...products]..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted;
}

List<Product> _heroPicks(List<Product> products) =>
    _topRated(products).where((p) => p.isSponsored).take(3).toList();

List<Product> _featurePicks(List<Product> products) {
  final heroIds = _heroPicks(products).map((p) => p.id).toSet();
  return _topRated(products)
      .where((p) => !heroIds.contains(p.id))
      .take(6)
      .toList();
}

List<Product> _gridPicks(List<Product> products) {
  final heroIds = _heroPicks(products).map((p) => p.id).toSet();
  final pool = products.where((p) => !heroIds.contains(p.id)).toList();

  final groups = <String, List<Product>>{};
  for (final p in pool) {
    groups.putIfAbsent(p.category, () => []).add(p);
  }

  final result = <Product>[];
  var round = 0;
  while (result.length < pool.length) {
    for (final group in groups.values) {
      if (round < group.length) result.add(group[round]);
    }
    round++;
  }
  return result.take(12).toList();
}

const _twoWordBrands = {'Hydro', 'Calvin', 'Pura'};

String _brandOf(Product p) {
  final words = p.title.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return '';
  if (words.length > 1 && _twoWordBrands.contains(words.first)) {
    return '${words[0]} ${words[1]}';
  }
  return words.first;
}

class _BrandPick {
  final String brand;
  final Product product;
  const _BrandPick(this.brand, this.product);
}

List<_BrandPick> _brandPicks(List<Product> products) {
  final seen = <String>{};
  final picks = <_BrandPick>[];
  for (final p in _topRated(products).where((p) => p.isSponsored)) {
    final brand = _brandOf(p);
    if (brand.isNotEmpty && seen.add(brand.toLowerCase())) {
      picks.add(_BrandPick(brand, p));
    }
    if (picks.length == 6) break;
  }
  return picks;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Product>> _productsFuture = ProductService.fetchProducts();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    _searchController.clear();
    _openSearch(context, q);
  }

  Future<void> _refresh() async {
    final future = ProductService.fetchProducts();
    setState(() => _productsFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final products = snapshot.data ?? const <Product>[];
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF6B0F), Color(0xFFFFAA6B)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _QuickLinks(products: products),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                        child: CustomSearchBar(
                          controller: _searchController,
                          onSubmitted: _search,
                          hintText: 'Search or ask a question',
                          showMic: true,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: _DeliveryBar(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _HeroRow(products: products),
              const SizedBox(height: 12),
              _FeatureCards(products: products),
              const SizedBox(height: 16),
              _ThumbGrid(products: products),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'Brands related to your search',
                sponsored: true,
              ),
              const SizedBox(height: 12),
              _BrandCards(products: products),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Recommended deals for you'),
              const SizedBox(height: 12),
              _DealsRow(products: products, loading: loading),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ImageBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final Color color;
  final Color iconColor;
  final IconData icon;

  const _ImageBox({
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
        child: ColoredBox(
          color: color,
          child: Center(child: Icon(icon, size: 32, color: iconColor)),
        ),
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;

  const _NetImage(this.url, {this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE3E6E6),
        child: const Icon(Icons.image_not_supported, color: Colors.black38),
      ),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              width: width,
              height: height,
              color: const Color(0xFFE3E6E6),
            ),
    );
  }
}

const _tileColors = <String, Color>{
  'Laptops': Color(0xFFE6EEFB),
  'Bottles': Color(0xFFEAF5F0),
  'Watch': Color(0xFFFFECEC),
  'Mobile Phones': Color(0xFFE3F4F5),
  'Shampoo': Color(0xFFFFF1D1),
  'Perfume': Color(0xFFF5E8F8),
  'Juice Mixers': Color(0xFFFFF1D1),
};

class _QuickLinks extends StatelessWidget {
  final List<Product> products;
  const _QuickLinks({required this.products});

  static const _count = 5;

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesOf(products).take(_count).toList();
    final topRated = _topRated(products);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (var i = 0; i < _count; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: i < categories.length
                  ? GestureDetector(
                      onTap: () => _openSearch(context, categories[i]),
                      child: _QuickLinkTile(
                        label: categories[i],
                        imageUrl: topRated
                            .firstWhere((p) => p.category == categories[i])
                            .imageUrl,
                        background: _tileColors[categories[i]] ??
                            const Color(0xFFF1F1F1),
                      ),
                    )
                  : const _QuickLinkTile(background: Color(0xFFF1F1F1)),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final String? label;
  final String? imageUrl;
  final Color background;

  const _QuickLinkTile({
    this.label,
    this.imageUrl,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 46,
              width: double.infinity,
              child: imageUrl != null
                  ? _NetImage(imageUrl!)
                  : const ColoredBox(color: Color(0xFFE3E6E6)),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: label == null
                  ? null
                  : Text(
                      label!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F1111),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryBar extends StatelessWidget {
  const _DeliveryBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(120),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 24,
            color: Color(0xFF0F1111),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'Deliver to 781017',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F1111),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Color(0xFF0F1111),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A7CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Join Prime',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRow extends StatelessWidget {
  final List<Product> products;
  const _HeroRow({required this.products});

  static const _colors = [
    Color(0xFF3B4A6B),
    Color(0xFF2F2F2F),
    Color(0xFF6B4F3A),
  ];
  static const _icons = [Icons.checkroom, Icons.keyboard, Icons.watch];

  @override
  Widget build(BuildContext context) {
    final picks = _heroPicks(products);

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: picks.isEmpty ? _colors.length : picks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (picks.isEmpty) {
            return _ImageBox(
              width: 300,
              height: 320,
              radius: 16,
              color: _colors[i],
              iconColor: Colors.white70,
              icon: _icons[i],
            );
          }

          final p = picks[i];
          return GestureDetector(
            onTap: () => _openProduct(context, p),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 300,
                height: 320,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _NetImage(p.imageUrl),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _price(p.price),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureCards extends StatelessWidget {
  final List<Product> products;
  const _FeatureCards({required this.products});

  static const _icons = [
    Icons.tablet_mac,
    Icons.keyboard_alt_outlined,
    Icons.headphones,
    Icons.watch_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final picks = _featurePicks(products);

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: picks.isEmpty ? _icons.length : picks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (picks.isEmpty) {
            return _ImageBox(
              width: 160,
              height: 150,
              radius: 14,
              icon: _icons[i],
            );
          }

          final p = picks[i];
          return GestureDetector(
            onTap: () => _openProduct(context, p),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 160,
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _NetImage(p.imageUrl),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(235),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _price(p.price),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThumbGrid extends StatelessWidget {
  final List<Product> products;
  const _ThumbGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final picks = _gridPicks(products);

    return GridView.count(
      crossAxisCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(12, (i) {
        if (i >= picks.length) return const _ImageBox(radius: 8);

        final p = picks[i];
        return GestureDetector(
          onTap: () => _openProduct(context, p),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _NetImage(p.imageUrl),
          ),
        );
      }),
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
  final List<Product> products;
  const _BrandCards({required this.products});

  static const _names = ['Mac', 'Mi', 'Samsung'];
  static const _icons = [Icons.laptop_mac, Icons.smartphone, Icons.tv];

  @override
  Widget build(BuildContext context) {
    final picks = _brandPicks(products);

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: picks.isEmpty ? _names.length : picks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final String name;
          final Widget image;
          VoidCallback? onTap;

          if (picks.isEmpty) {
            name = _names[i];
            image = _ImageBox(
              width: double.infinity,
              radius: 12,
              icon: _icons[i],
            );
          } else {
            final pick = picks[i];
            name = pick.brand;
            image = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _NetImage(pick.product.imageUrl, width: double.infinity),
            );
            onTap = () => _openSearch(context, pick.brand);
          }

          return GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: 280,
              child: Column(
                children: [
                  Expanded(child: image),
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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DealsRow extends StatelessWidget {
  final List<Product> products;
  final bool loading;
  const _DealsRow({required this.products, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SizedBox(
        height: loading ? 230 : 100,
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : const Text('No products available'),
        ),
      );
    }

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
            onTap: () => _openProduct(context, product),
            child: SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _NetImage(product.imageUrl, width: 150, height: 150),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _price(product.price),
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
  }
}
