import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/intl.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/providers/wishlist_provider.dart';

class WishlistPage extends StatelessWidget {
  static const String routeName = '/wishlist';

  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();

    if (!user.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Wish List')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Sign in to view your Wish List',
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

    if (wishlistProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Wish List')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final wishlist = wishlistProvider.wishlist;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Wish List (${wishlist.length})'),
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Text(
                'Your Wish List is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: wishlist.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE3E6E6)),
              itemBuilder: (context, index) {
                final product = wishlist[index];

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ProductDetailScreen.routeName,
                      arguments: product,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.network(
                            product.imageUrl,
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
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${NumberFormatters.formatIndianCurrency(product.price)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await context
                                          .read<CartProvider>()
                                          .addToCart(
                                            user.token!,
                                            product.id,
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Added to Cart'),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD814),
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('Add to Cart',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      wishlistProvider.toggleWishlist(
                                        user.token!,
                                        product.id,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFD5D9D9)),
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('Remove',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
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
