class ProductFilters {
  String? category;
  double? minPrice;
  double? maxPrice;
  double? minRating;
  Map<String, Set<String>> enums;
  Map<String, Set<num>> numerics;
  Map<String, bool> bools;

  ProductFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    Map<String, Set<String>>? enums,
    Map<String, Set<num>>? numerics,
    Map<String, bool>? bools,
  })  : enums = enums != null
            ? Map.fromEntries(
                enums.entries.map((e) => MapEntry(e.key, Set.from(e.value))))
            : {},
        numerics = numerics != null
            ? Map.fromEntries(
                numerics.entries.map((e) => MapEntry(e.key, Set.from(e.value))))
            : {},
        bools = bools != null ? Map.from(bools) : {};

  ProductFilters copy() {
    return ProductFilters(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      enums: enums,
      numerics: numerics,
      bools: bools,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (category != null && category!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minRating != null) count++;
    enums.forEach((_, set) {
      if (set.isNotEmpty) count++;
    });
    numerics.forEach((_, set) {
      if (set.isNotEmpty) count++;
    });
    bools.forEach((_, val) {
      if (val == true) count++;
    });
    return count;
  }

  void clear() {
    category = null;
    minPrice = null;
    maxPrice = null;
    minRating = null;
    enums.clear();
    numerics.clear();
    bools.clear();
  }

  void clearAttributes() {
    enums.clear();
    numerics.clear();
    bools.clear();
  }

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (category != null && category!.isNotEmpty) {
      params['category'] = category!;
    }
    if (minPrice != null) params['minPrice'] = minPrice!.toStringAsFixed(0);
    if (maxPrice != null) params['maxPrice'] = maxPrice!.toStringAsFixed(0);
    if (minRating != null) params['minRating'] = minRating!.toString();

    enums.forEach((key, set) {
      if (set.isNotEmpty) {
        params[key] = set.join(',');
      }
    });

    numerics.forEach((key, set) {
      if (set.isNotEmpty) {
        params[key] = set.join(',');
      }
    });

    bools.forEach((key, val) {
      if (val) {
        params[key] = 'true';
      }
    });

    return params;
  }
}
