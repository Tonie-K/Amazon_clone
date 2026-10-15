import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/constants/api_config.dart';
import 'package:flutter_application_1/models/product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/get/products'),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final List<dynamic> data = body['response'] ?? [];
        return data.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<Product>> searchProducts(String searchQuery) async {
    try {
      final encodedQuery = Uri.encodeComponent(searchQuery.trim());
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/products/search/$encodedQuery'),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        final List<dynamic> data = body['response'] ?? [];
        return data.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
}
