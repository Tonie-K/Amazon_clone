import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _wishlist = [];
  bool _isLoading = false;

  List<Product> get wishlist => _wishlist;
  bool get isLoading => _isLoading;

  bool isWishlisted(String productId) {
    return _wishlist.any((item) => item.id == productId);
  }

  void clear() {
    _wishlist = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWishlist(String token) async {
    _isLoading = true;
    notifyListeners();
    _wishlist = await WishlistService.fetchWishlist(token);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWishlist(String token, String productId) async {
    if (isWishlisted(productId)) {
      _wishlist = await WishlistService.removeFromWishlist(token, productId);
    } else {
      _wishlist = await WishlistService.addToWishlist(token, productId);
    }
    notifyListeners();
  }
}
