import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/intl.dart';
import 'package:flutter_application_1/models/cart_item.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isGift = false;
  final Set<String> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>();
      if (user.isLoggedIn && user.token != null) {
        context.read<CartProvider>().fetchCart(user.token!).then((_) {
          final items = context.read<CartProvider>().cart;
          setState(() {
            _selectedProductIds.addAll(items.map((e) => e.product.id));
          });
        });
      }
    });
  }

  void _toggleSelectAll(List<CartItem> items) {
    setState(() {
      if (_selectedProductIds.length == items.length) {
        _selectedProductIds.clear();
      } else {
        _selectedProductIds.clear();
        _selectedProductIds.addAll(items.map((e) => e.product.id));
      }
    });
  }

  void _proceedToCheckout(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.cart.isEmpty) return;

    setState(() {
      _selectedProductIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final cartProvider = context.watch<CartProvider>();

    if (!user.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Sign in to view your cart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD814),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Sign In',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    if (cartProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cartItems = cartProvider.cart;
    double selectedTotal = 0.0;
    int selectedItemCount = 0;

    for (final item in cartItems) {
      if (_selectedProductIds.contains(item.product.id)) {
        selectedTotal += item.product.price * item.quantity;
        selectedItemCount += item.quantity;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your Amazon Cart is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Subtotal Header Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                        Text(
                          NumberFormatters.formatIndianCurrency(selectedTotal),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Yellow Proceed to Buy Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _proceedToCheckout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD814),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Proceed to Buy ($selectedItemCount items)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Send as Gift Checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _isGift,
                            activeColor: const Color(0xFF007185),
                            side: const BorderSide(color: Color(0xFF888C8C)),
                            onChanged: (val) {
                              setState(() => _isGift = val ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Send as a gift. Include custom message',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Rewards Line
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Use ₹33',
                          style:
                              TextStyle(fontSize: 15, color: Color(0xFF0F1111)),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF007185),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 5. Horizontal Cashback Cards
                  SizedBox(
                    height: 72,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCashbackCard(
                          title: '₹25 cashback unlocked!',
                          subtitle: 'Pay with Amazon Pay UPI',
                        ),
                        const SizedBox(width: 10),
                        _buildCashbackCard(
                          title: '₹10 cashback offer',
                          subtitle: 'Pay via Net Banking',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. Select / Deselect All Action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => _toggleSelectAll(cartItems),
                      child: Text(
                        _selectedProductIds.length == cartItems.length
                            ? 'Deselect all items'
                            : 'Select all items',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF007185),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 7. Cart Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE3E6E6)),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final isSelected =
                          _selectedProductIds.contains(item.product.id);

                      return _CartItemTile(
                        item: item,
                        isSelected: isSelected,
                        onToggleSelect: () {
                          setState(() {
                            if (isSelected) {
                              _selectedProductIds.remove(item.product.id);
                            } else {
                              _selectedProductIds.add(item.product.id);
                            }
                          });
                        },
                        onQuantityChanged: (newQty) {
                          cartProvider.updateQuantity(
                            user.token!,
                            item.product.id,
                            newQty,
                          );
                        },
                        onDelete: () {
                          cartProvider.updateQuantity(
                            user.token!,
                            item.product.id,
                            0,
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 8. Offers Banner
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF8FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBCE3E8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Save extra with offers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'See offers >',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF007185),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 9. Prime Banner Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066C0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Festive savings only for Prime!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD814),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Extra 5% off on lakhs of products',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unlock Prime savings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD814),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildCashbackCard({required String title, required String subtitle}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD5D9D9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF008296), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007600),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF565959),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  const _CartItemTile({
    required this.item,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8F8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF007185),
                  side: const BorderSide(color: Color(0xFF888C8C)),
                  onChanged: (_) => onToggleSelect(),
                ),
              ),
              const SizedBox(width: 8),

              // Product Image
              SizedBox(
                width: 100,
                height: 120,
                child: Image.network(
                  item.product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F1111),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Best Seller / Deal Badge
                    if (item.product.isSponsored)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE67A00),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          '#1 Best Seller',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),
                    const Text(
                      '100+ bought in past month',
                      style: TextStyle(fontSize: 12, color: Color(0xFF565959)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Limited time deal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCC0C39),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCC0C39),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            '-69%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹${NumberFormatters.formatIndianCurrency(item.product.price)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                        const Text(
                          '00',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.superscripts()],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),
                    Text(
                      'M.R.P.: ₹${NumberFormatters.formatIndianCurrency(item.product.price * 1.5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Color(0xFF565959),
                      ),
                    ),
                    const SizedBox(height: 4),

                    const Text(
                      'FREE delivery Thu, 22 Oct',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F1111),
                      ),
                    ),
                    const Text(
                      'available at checkout',
                      style: TextStyle(fontSize: 12, color: Color(0xFF565959)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'In stock',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF007600),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '10 days Returnable',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF007185),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons Pill Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Quantity Selector Box
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD5D9D9)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        icon: item.quantity == 1
                            ? const Icon(Icons.delete_outline,
                                color: Colors.black87)
                            : const Icon(Icons.remove, color: Colors.black87),
                        onPressed: () => onQuantityChanged(item.quantity - 1),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1111),
                        ),
                      ),
                      IconButton(
                        iconSize: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.add, color: Colors.black87),
                        onPressed: () => onQuantityChanged(item.quantity + 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Delete Button
                _buildActionPill(
                  label: 'Delete',
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),

                // Save for later
                _buildActionPill(
                  label: 'Save',
                  onTap: () {},
                ),
                const SizedBox(width: 8),

                // Share Button
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD5D9D9)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.share_outlined,
                        size: 18, color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD5D9D9)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF0F1111),
          ),
        ),
      ),
    );
  }
}
