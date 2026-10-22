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

class FacetCategory {
  final String name;
  final int count;

  FacetCategory({required this.name, required this.count});

  factory FacetCategory.fromJson(Map<String, dynamic> json) {
    return FacetCategory(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class FacetOption {
  final dynamic value;
  final int count;

  FacetOption({required this.value, required this.count});

  factory FacetOption.fromJson(Map<String, dynamic> json) {
    return FacetOption(
      value: json['value'],
      count: json['count'] ?? 0,
    );
  }
}

class FacetAttribute {
  final String key;
  final String label;
  final String type;
  final String unit;
  final int trueCount;
  final List<FacetOption> options;

  FacetAttribute({
    required this.key,
    required this.label,
    required this.type,
    required this.unit,
    this.trueCount = 0,
    this.options = const [],
  });

  factory FacetAttribute.fromJson(Map<String, dynamic> json) {
    return FacetAttribute(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      unit: json['unit'] ?? '',
      trueCount: json['trueCount'] ?? 0,
      options: (json['options'] as List? ?? [])
          .map((o) => FacetOption.fromJson(o))
          .toList(),
    );
  }
}

class FacetResponse {
  final int total;
  final String? selectedCategory;
  final double minPrice;
  final double maxPrice;
  final List<FacetCategory> categories;
  final List<FacetAttribute> attributes;

  FacetResponse({
    required this.total,
    this.selectedCategory,
    required this.minPrice,
    required this.maxPrice,
    required this.categories,
    required this.attributes,
  });

  factory FacetResponse.fromJson(Map<String, dynamic> json) {
    final price = json['price'] ?? {};
    return FacetResponse(
      total: json['total'] ?? 0,
      selectedCategory: json['selectedCategory']?.toString(),
      minPrice: (price['min'] as num?)?.toDouble() ?? 0,
      maxPrice: (price['max'] as num?)?.toDouble() ?? 100000,
      categories: (json['categories'] as List? ?? [])
          .map((c) => FacetCategory.fromJson(c))
          .toList(),
      attributes: (json['attributes'] as List? ?? [])
          .map((a) => FacetAttribute.fromJson(a))
          .toList(),
    );
  }
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

  static Future<FacetResponse> fetchFacets({
    required String searchQuery,
    required ProductFilters filters,
  }) async {
    final Map<String, String> queryParams = filters.toQueryParams();
    if (searchQuery.isNotEmpty) {
      queryParams['q'] = searchQuery;
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/products/facets')
        .replace(queryParameters: queryParams);

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return FacetResponse.fromJson(data);
    }
    return FacetResponse(
      total: 0,
      minPrice: 0,
      maxPrice: 100000,
      categories: [],
      attributes: [],
    );
  }
}
