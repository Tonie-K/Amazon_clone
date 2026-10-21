import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/product_filters.dart';
import '../services/product_service.dart';

class FilterScreen extends StatefulWidget {
  final ProductFilters currentFilters;

  const FilterScreen({super.key, required this.currentFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late ProductFilters _tempFilters;
  List<Map<String, dynamic>> _definitions = [];
  bool _loading = true;
  double _minPriceBound = 0;
  double _maxPriceBound = 100000;

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.currentFilters;
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final facets = await ProductService.fetchFacets(_tempFilters);
      if (facets.containsKey('minPrice')) {
        _minPriceBound = (facets['minPrice'] as num).toDouble();
        _maxPriceBound = (facets['maxPrice'] as num).toDouble();
      }

      if (_tempFilters.category != null && _tempFilters.category!.isNotEmpty) {
        final cat = Uri.encodeComponent(_tempFilters.category!);
        final res = await http.get(Uri.parse(
            '${ApiConfig.baseUrl}/api/v1/categories/$cat/attributes'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _definitions =
              List<Map<String, dynamic>>.from(data['definitions'] ?? []);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _tempFilters.clear());
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Price Range',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                RangeSlider(
                  values: RangeValues(
                    _tempFilters.minPrice ?? _minPriceBound,
                    _tempFilters.maxPrice ?? _maxPriceBound,
                  ),
                  min: _minPriceBound,
                  max: _maxPriceBound > _minPriceBound
                      ? _maxPriceBound
                      : _minPriceBound + 1000,
                  onChanged: (RangeValues vals) {
                    setState(() {
                      _tempFilters.minPrice = vals.start;
                      _tempFilters.maxPrice = vals.end;
                    });
                  },
                ),
                const Divider(),
                ..._definitions.map((def) => _buildDynamicField(def)),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD814)),
          onPressed: () => Navigator.pop(context, _tempFilters),
          child: const Text('Apply Filters',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDynamicField(Map<String, dynamic> def) {
    final key = def['key'];
    final label = def['label'] ?? key;
    final type = def['type'];

    if (type == 'bool') {
      return SwitchListTile(
        title: Text(label),
        value: _tempFilters.bools[key] ?? false,
        onChanged: (val) {
          setState(() {
            _tempFilters.bools[key] = val;
          });
        },
      );
    }

    return const SizedBox.shrink();
  }
}
