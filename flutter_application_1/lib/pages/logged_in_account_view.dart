import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/pages/wishlist_page.dart';

/// Logged-in "You" page content (header, quick pills, Your Orders,
/// Buy Again, Keep shopping for).
/// Place at: lib/pages/logged_in_account_view.dart
class LoggedInAccountView extends StatelessWidget {
  const LoggedInAccountView({super.key});

  // TODO: replace with real data from your providers / backend.
  static const List<_CardItem> _orders = [
    _CardItem(image: 'assets/images/yonex_grip.png'),
    _CardItem(image: 'assets/images/razor.png'),
    _CardItem(image: 'assets/images/razor.png'),
  ];

  static const List<_CardItem> _buyAgain = [
    _CardItem(image: 'assets/images/buldak.png'),
    _CardItem(image: 'assets/images/newtone_bags.png'),
    _CardItem(image: 'assets/images/razor.png'),
  ];

  static const List<_CardItem> _keepShopping = [
    _CardItem(image: 'assets/images/laptop.png', label: 'Laptops'),
    _CardItem(
        image: 'assets/images/basketball_shoes.png',
        label: "Men's basketball shoes"),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return SingleChildScrollView(
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
                const SizedBox(width: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.asset(
                    'assets/images/flag.png',
                    width: 18,
                    height: 12,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'EN',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),

          // ---------- Quick pills ----------
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

          // ---------- Your Orders ----------
          _SectionHeader(title: 'Your Orders', onTap: () {}),
          _HorizontalCards(items: _orders, height: 150, width: 160),
          const SizedBox(height: 24),

          // ---------- Buy Again ----------
          _SectionHeader(title: 'Buy Again', onTap: () {}),
          _HorizontalCards(items: _buyAgain, height: 110, width: 110),
          const SizedBox(height: 24),

          // ---------- Keep shopping for ----------
          _SectionHeader(title: 'Keep shopping for', onTap: () {}),
          _HorizontalCards(items: _keepShopping, height: 140, width: 150),
          const SizedBox(height: 24),

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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Helper widgets =======================

class _CardItem {
  final String image;
  final String? label;
  const _CardItem({required this.image, this.label});
}

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
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F1111),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: const Icon(Icons.arrow_forward, size: 28),
          ),
        ],
      ),
    );
  }
}

class _HorizontalCards extends StatelessWidget {
  final List<_CardItem> items;
  final double height;
  final double width;
  const _HorizontalCards({
    required this.items,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = items.any((i) => i.label != null);

    return SizedBox(
      height: height + (hasLabel ? 28 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: height,
                  width: width,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD5D9D9)),
                  ),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (item.label != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}