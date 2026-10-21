import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/constants/api_config.dart';
import 'package:flutter_application_1/models/product.dart';

class WishlistService {
  static Future<List<Product>> fetchWishlist(String token) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/get/wishlist'),
        headers: {'authorization': token},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['wishlist'] ?? [];
        return list.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<Product>> addToWishlist(
      String token, String productId) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/wishlist/add'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': token,
        },
        body: jsonEncode({'productId': productId}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['wishlist'] ?? [];
        return list.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<Product>> removeFromWishlist(
      String token, String productId) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/wishlist/remove/$productId'),
        headers: {'authorization': token},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['wishlist'] ?? [];
        return list.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
