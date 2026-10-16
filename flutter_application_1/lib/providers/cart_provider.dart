import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/cart_item.dart';
import 'package:flutter_application_1/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cart = [];
  bool _isLoading = false;

  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;

  double get totalAmount => _cart.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  int get itemCount => _cart.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();
    _cart = await CartService.fetchCart(token);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(String token, String productId) async {
    _cart = await CartService.addToCart(token, productId);
    notifyListeners();
  }

  Future<void> updateQuantity(
      String token, String productId, int quantity) async {
    _cart = await CartService.updateQuantity(token, productId, quantity);
    notifyListeners();
  }

  Future<bool> checkout(String token, String address) async {
    _isLoading = true;
    notifyListeners();
    final success = await CartService.checkout(token, _cart, address);
    if (success) {
      _cart = [];
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
