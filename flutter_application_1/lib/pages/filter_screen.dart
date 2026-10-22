import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_filters.dart';
import '../services/product_service.dart';

class FilterScreen extends StatefulWidget {
  final ProductFilters currentFilters;
  final String searchQuery;

  const FilterScreen({
    super.key,
    required this.currentFilters,
    required this.searchQuery,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late ProductFilters _draftFilters;
  FacetResponse? _facetData;
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _draftFilters = widget.currentFilters.copy();
    _loadFacets();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFilterChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _loadFacets();
    });
  }

  Future<void> _loadFacets() async {
    setState(() => _isLoading = true);
    final response = await ProductService.fetchFacets(
      searchQuery: widget.searchQuery,
      filters: _draftFilters,
    );

    if (!mounted) return;

    setState(() {
      _facetData = response;
      _isLoading = false;

      // Automatically assign category if backend inferred one from search query (e.g., 'laptop' -> 'Laptops')
      if (_draftFilters.category == null && response.selectedCategory != null) {
        _draftFilters.category = response.selectedCategory;
      }
    });
  }

  void _selectCategory(String catName) {
    setState(() {
      if (_draftFilters.category == catName) {
        _draftFilters.category = null;
      } else {
        _draftFilters.category = catName;
      }
      _draftFilters.clearAttributes();
    });
    _onFilterChanged();
  }

  @override
  Widget build(BuildContext context) {
    final facets = _facetData;
    final totalCount = facets?.total ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Filters', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _draftFilters.clear());
              _onFilterChanged();
            },
            child:
                const Text('Reset', style: TextStyle(color: Color(0xFF007185))),
          )
        ],
      ),
      body: _isLoading && facets == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Category Section
                if (facets != null && facets.categories.isNotEmpty) ...[
                  const Text('Category',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facets.categories.map((cat) {
                      final isSelected = _draftFilters.category == cat.name;
                      return FilterChip(
                        selected: isSelected,
                        label: Text('${cat.name} (${cat.count})'),
                        selectedColor: const Color(0xFFE2F3F5),
                        checkmarkColor: const Color(0xFF007185),
                        onSelected: (_) => _selectCategory(cat.name),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 32),
                ],

                // 2. Price Range
                if (facets != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price Range',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '₹${(_draftFilters.minPrice ?? facets.minPrice).toInt()} - ₹${(_draftFilters.maxPrice ?? facets.maxPrice).toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(
                      _draftFilters.minPrice ?? facets.minPrice,
                      _draftFilters.maxPrice ?? facets.maxPrice,
                    ),
                    min: facets.minPrice,
                    max: facets.maxPrice > facets.minPrice
                        ? facets.maxPrice
                        : facets.minPrice + 1000,
                    activeColor: const Color(0xFF007185),
                    onChanged: (RangeValues vals) {
                      setState(() {
                        _draftFilters.minPrice = vals.start;
                        _draftFilters.maxPrice = vals.end;
                      });
                      _onFilterChanged();
                    },
                  ),
                  const Divider(height: 32),
                ],

                // 3. Customer Rating
                const Text('Customer Rating',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [4.0, 3.0, 2.0, 1.0].map((rating) {
                    final isSelected = _draftFilters.minRating == rating;
                    return ChoiceChip(
                      label: Text('${rating.toInt()}★ & up'),
                      selected: isSelected,
                      selectedColor: const Color(0xFFE2F3F5),
                      onSelected: (selected) {
                        setState(() {
                          _draftFilters.minRating = selected ? rating : null;
                        });
                        _onFilterChanged();
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 32),

                // 4. Dynamic Attributes (Category required)
                if (_draftFilters.category != null && facets != null)
                  ...facets.attributes
                      .map((attr) => _buildAttributeWidget(attr)),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE3E6E6))),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD814),
            minimumSize: const Size(double.infinity, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: () => Navigator.pop(context, _draftFilters),
          child: Text(
            'Show $totalCount results',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeWidget(FacetAttribute attr) {
    if (attr.type == 'bool') {
      if (attr.trueCount == 0) return const SizedBox.shrink();

      final currentVal = _draftFilters.bools[attr.key] ?? false;
      return Column(
        children: [
          SwitchListTile(
            title: Text('${attr.label} (${attr.trueCount})'),
            value: currentVal,
            activeColor: const Color(0xFF007185),
            onChanged: (val) {
              setState(() {
                _draftFilters.bools[attr.key] = val;
              });
              _onFilterChanged();
            },
          ),
          const Divider(),
        ],
      );
    }

    if (attr.type == 'enum') {
      final selectedSet = _draftFilters.enums[attr.key] ?? {};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(attr.label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attr.options.map((opt) {
              final val = opt.value.toString();
              final isSelected = selectedSet.contains(val);
              return FilterChip(
                label: Text('$val (${opt.count})'),
                selected: isSelected,
                selectedColor: const Color(0xFFE2F3F5),
                checkmarkColor: const Color(0xFF007185),
                onSelected: (selected) {
                  setState(() {
                    final set =
                        _draftFilters.enums.putIfAbsent(attr.key, () => {});
                    if (selected) {
                      set.add(val);
                    } else {
                      set.remove(val);
                    }
                  });
                  _onFilterChanged();
                },
              );
            }).toList(),
          ),
          const Divider(height: 32),
        ],
      );
    }

    if (attr.type == 'number') {
      final selectedSet = _draftFilters.numerics[attr.key] ?? {};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${attr.label} (${attr.unit})',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attr.options.map((opt) {
              final numVal = opt.value as num;
              final isSelected = selectedSet.contains(numVal);
              return ChoiceChip(
                label: Text('${opt.value} ${attr.unit} (${opt.count})'),
                selected: isSelected,
                selectedColor: const Color(0xFFE2F3F5),
                onSelected: (selected) {
                  setState(() {
                    final set =
                        _draftFilters.numerics.putIfAbsent(attr.key, () => {});
                    if (selected) {
                      set.add(numVal);
                    } else {
                      set.remove(numVal);
                    }
                  });
                  _onFilterChanged();
                },
              );
            }).toList(),
          ),
          const Divider(height: 32),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
