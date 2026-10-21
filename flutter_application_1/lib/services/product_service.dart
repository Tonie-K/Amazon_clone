import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/product.dart';
import '../models/product_filters.dart';

class SearchResult {
  final List<Product> products;
  final int totalPages;
  final int totalProducts;

  SearchResult({
    required this.products,
    required this.totalPages,
    required this.totalProducts,
  });
}

class ProductService {
  static Future<SearchResult> searchProducts({
    String query = '',
    required ProductFilters filters,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, String> queryParams = filters.toQueryParams();
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    final encodedQuery = Uri.encodeComponent(query);
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/products/search/$encodedQuery')
            .replace(queryParameters: queryParams);

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List rawProducts = data['response'] ?? [];
      final pagination = data['pagination'] ?? {};

      final products = rawProducts.map((e) => Product.fromJson(e)).toList();

      return SearchResult(
        products: products,
        totalPages: pagination['totalPages'] ?? 1,
        totalProducts: pagination['total'] ?? products.length,
      );
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Map<String, dynamic>> fetchFacets(
      ProductFilters filters) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/products/facets')
        .replace(queryParameters: filters.toQueryParams());

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['facets'] ?? {};
    }
    return {};
  }
}
