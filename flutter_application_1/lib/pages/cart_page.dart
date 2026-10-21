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

  Future<void> _proceedToCheckout() async {
    final cartProvider = context.read<CartProvider>();
    final userProvider = context.read<UserProvider>();

    if (cartProvider.cart.isEmpty || !userProvider.isLoggedIn) return;

    final success = await cartProvider.checkout(
      userProvider.token!,
      "Default Address, Guwahati, Assam - 781017",
    );

    if (!mounted) return;

    if (success) {
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

    if (_selectedProductIds.isEmpty && cartItems.isNotEmpty) {
      _selectedProductIds.addAll(cartItems.map((e) => e.product.id));
    }

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

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _proceedToCheckout,
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

                  // 5. Cart Items List
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

                  const SizedBox(height: 24),
                ],
              ),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${NumberFormatters.formatIndianCurrency(item.product.price)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1111),
                          ),
                        ),
                      ],
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
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
                _buildActionPill(
                  label: 'Delete',
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),
                _buildActionPill(
                  label: 'Save',
                  onTap: () {},
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
