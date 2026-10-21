import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/constants/api_config.dart';
import 'package:flutter_application_1/models/cart_item.dart';

class CartService {
  static Future<List<CartItem>> fetchCart(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/get/cart'),
        headers: {'authorization': token},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['cart'] ?? [];
        return list.map((item) => CartItem.fromJson(item)).toList();
      }
      debugPrint('Fetch Cart Error: ${res.statusCode} ${res.body}');
      return [];
    } catch (e, stack) {
      debugPrint('Fetch Cart Exception: $e\n$stack');
      return [];
    }
  }

  static Future<List<CartItem>> addToCart(String token, String productId,
      {int quantity = 1}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/cart/add'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['cart'] ?? [];
        return list.map((item) => CartItem.fromJson(item)).toList();
      }
      debugPrint('Add to Cart Error: ${res.statusCode} ${res.body}');
      return [];
    } catch (e, stack) {
      debugPrint('Add to Cart Parsing Exception: $e\n$stack');
      return [];
    }
  }

  static Future<List<CartItem>> updateQuantity(
      String token, String productId, int quantity) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/cart/update'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['cart'] ?? [];
        return list.map((item) => CartItem.fromJson(item)).toList();
      }
      debugPrint('Update Quantity Error: ${res.statusCode} ${res.body}');
      return [];
    } catch (e, stack) {
      debugPrint('Update Quantity Exception: $e\n$stack');
      return [];
    }
  }

  static Future<bool> checkout(
      String token, List<CartItem> cart, String address) async {
    try {
      final double totalAmount = cart.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      final productsPayload = cart
          .map((item) => {
                'product': item.product.id,
                'quantity': item.quantity,
              })
          .toList();

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/add/order'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
        body: jsonEncode({
          'products': productsPayload,
          'totalAmount': totalAmount,
          'address': address,
        }),
      );

      if (res.statusCode == 201) {
        await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/api/v1/cart/clear'),
          headers: {'authorization': token},
        );
        return true;
      }
      debugPrint('Checkout Error: ${res.statusCode} ${res.body}');
      return false;
    } catch (e, stack) {
      debugPrint('Checkout Exception: $e\n$stack');
      return false;
    }
  }
}
