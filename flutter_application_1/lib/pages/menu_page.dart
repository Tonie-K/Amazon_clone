import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/pages/wishlist_page.dart';

/// Menu / Browse page.
/// Place at: lib/pages/menu_page.dart
///
/// Every item shows a built-in icon tile, so no asset files are required.
/// To use your own artwork later, pass `asset: 'assets/images/...png'` to any
/// _MenuItem; the icon is then used only as a fallback.
class MenuPage extends StatefulWidget {
  static const String routeName = '/menu';
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;

  // ---------------- Sidebar data ----------------
  static const List<_MenuItem> _sidebar = [
    _MenuItem('Top Picks', Icons.auto_awesome, Color(0xFFF5A623)),
    _MenuItem('Amazon Pay', Icons.account_balance_wallet, Color(0xFF37475A)),
    _MenuItem('Mobiles & Electronics', Icons.devices, Color(0xFF1E88E5)),
    _MenuItem('Deals & Savings', Icons.local_offer, Color(0xFFE53935)),
    _MenuItem('Fashion & Beauty', Icons.checkroom, Color(0xFFD81B60)),
    _MenuItem('Home & Furniture', Icons.chair, Color(0xFF8D6E63)),
    _MenuItem('Groceries & Pet Supplies', Icons.shopping_basket,
        Color(0xFF43A047)),
    _MenuItem('Books & Education', Icons.menu_book, Color(0xFF6D4C41)),
    _MenuItem('Video & Music', Icons.play_circle_fill, Color(0xFF3949AB)),
    _MenuItem('Prime', Icons.delivery_dining, Color(0xFF00A8E1)),
    _MenuItem('Games & Live Shopping', Icons.sports_esports,
        Color(0xFF8E24AA)),
    _MenuItem('Pharmacy & Household', Icons.medical_services,
        Color(0xFF00897B)),
    _MenuItem('Travel & Auto', Icons.flight, Color(0xFF039BE5)),
    _MenuItem('Toys & Kids', Icons.toys, Color(0xFFFF7043)),
    _MenuItem('Sports & Fitness', Icons.fitness_center, Color(0xFF546E7A)),
    _MenuItem('Gifting', Icons.card_giftcard, Color(0xFFC62828)),
    _MenuItem('Sell on Amazon', Icons.storefront, Color(0xFFEF6C00)),
    _MenuItem('Your Things', Icons.inventory_2, Color(0xFFA1887F)),
    _MenuItem('Account & Help', Icons.support_agent, Color(0xFF1976D2)),
  ];

  // ---------------- Right panel data ----------------
  static const List<_MenuItem> _topCategories = [
    _MenuItem('For you', Icons.celebration, Color(0xFFC62828)),
    _MenuItem('Mobiles', Icons.smartphone, Color(0xFF00897B)),
    _MenuItem('Fashion', Icons.checkroom, Color(0xFF1E88E5)),
    _MenuItem('Electronics', Icons.laptop_mac, Color(0xFF5E35B1)),
    _MenuItem('Travel', Icons.flight_takeoff, Color(0xFF039BE5)),
    _MenuItem('Deals', Icons.percent, Color(0xFFE53935)),
    _MenuItem('Home', Icons.kitchen, Color(0xFF6D4C41)),
    _MenuItem('Everyday Needs', Icons.local_grocery_store, Color(0xFF7CB342)),
    _MenuItem('Bills & Recharges', Icons.lightbulb, Color(0xFFFFB300)),
    _MenuItem('Beauty', Icons.face_retouching_natural, Color(0xFFD81B60)),
    _MenuItem('Appliances', Icons.local_laundry_service, Color(0xFF546E7A)),
    _MenuItem('Furniture', Icons.weekend, Color(0xFF3949AB)),
    _MenuItem('Kids & Toys', Icons.toys, Color(0xFFFF7043)),
  ];

  static const List<_MenuItem> _exploreMore = [
    _MenuItem('Prime', Icons.workspace_premium, Color(0xFF00A8E1)),
    _MenuItem('Business', Icons.business_center, Color(0xFF6A4FD8)),
    _MenuItem('Customer Service', Icons.headset_mic, Color(0xFF00677F)),
    _MenuItem('Budget Picks', Icons.savings, Color(0xFF7B1FA2)),
    _MenuItem('Under ₹999', Icons.price_change, Color(0xFFE64A19)),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Sidebar + content ----------
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),

            // ---------- Shortcuts ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shortcuts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ShortcutChip(label: 'Orders', onTap: () {}),
                        _ShortcutChip(label: 'Buy Again', onTap: () {}),
                        _ShortcutChip(label: 'Account', onTap: () {}),
                        _ShortcutChip(
                          label: 'Lists',
                          onTap: () => Navigator.pushNamed(
                              context, WishlistPage.routeName),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<UserProvider>().logout();
                        },
                        icon: const Icon(Icons.logout, color: Colors.black87),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: GlobalVariables.greyBackgroundCOlor,
                          side: const BorderSide(color: Color(0xFFD5D9D9)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'You are currently signed out.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Left sidebar ----------------
  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: const Color(0xFFF3F6F6),
      child: ListView.builder(
        itemCount: _sidebar.length,
        itemBuilder: (context, index) {
          final item = _sidebar[index];
          final selected = index == _selectedIndex;

          return InkWell(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFF3F6F6),
                border: Border(
                  left: BorderSide(
                    color:
                        selected ? const Color(0xFF007185) : Colors.transparent,
                    width: 4,
                  ),
                  bottom: const BorderSide(color: Color(0xFFE3E6E6)),
                ),
              ),
              child: Column(
                children: [
                  _MenuImage(item: item, size: 44),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w400,
                      color: const Color(0xFF0F1111),
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

  // ---------------- Right content ----------------
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: swap _topCategories per selected sidebar item
          // (e.g. a Map<String, List<_MenuItem>> keyed by _sidebar[_selectedIndex].label)
          const _SectionTitle('Top Categories For You'),
          const SizedBox(height: 12),
          const _MenuGrid(items: _topCategories),
          const SizedBox(height: 16),
          const _SectionTitle('Explore More'),
          const SizedBox(height: 12),
          const _MenuGrid(items: _exploreMore),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ======================= Helper widgets =======================

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final String? asset; // optional: your own image, icon is the fallback
  const _MenuItem(this.label, this.icon, this.color, {this.asset});
}

class _MenuImage extends StatelessWidget {
  final _MenuItem item;
  final double size;
  const _MenuImage({required this.item, required this.size});

  Widget _iconTile() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: item.color.withOpacity(0.14),
      ),
      child: Icon(item.icon, size: size * 0.55, color: item.color),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (item.asset == null) return _iconTile();

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        item.asset!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _iconTile(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F1111),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(color: Color(0xFFE3E6E6), thickness: 1, height: 1),
        ),
      ],
    );
  }
}

class _MenuGrid extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 6,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            // TODO: navigate to the category / product list page
          },
          child: Column(
            children: [
              _MenuImage(item: item, size: 64),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0F1111),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ShortcutChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F1111),
          side: const BorderSide(color: Color(0xFFD5D9D9)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}