import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  static const String routeName = '/filter-screen';

  final bool initialIsPrime;
  final List<String> initialSelectedFilters;
  final String searchQuery;

  const FilterScreen({
    super.key,
    this.initialIsPrime = false,
    this.initialSelectedFilters = const [],
    required this.searchQuery,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int _selectedCategoryIndex = 1; // Default to "Suggested Filters"
  late bool _isPrimeOnly;
  late List<String> _selectedFilters;

  final List<String> _sidebarCategories = const [
    'Continue\nShopping',
    'Suggested\nFilters',
    'Prime &\nDelivery',
    'Brands',
    'Customer\nReviews',
    'Price and\nDeals',
    'Screen Size',
    'RAM Size',
    'Connectivity',
    'Cellular\nTechnology',
  ];

  late final List<String> _filterOptions = _getFilterOptionsForQuery();

  List<String> _getFilterOptionsForQuery() {
    final queryLower = widget.searchQuery.toLowerCase();
    if (queryLower.contains('bottle')) {
      return [
        'Stainless Steel',
        'Insulated',
        'BPA Free',
        '1 Litre',
        'Copper',
        'Thermos',
        'Milton',
        'Cello',
        '4★ & Up',
      ];
    }
    // Default Laptop options matching Amazon UI
    return [
      'Great Indian Festival',
      'Most Purchased',
      'Value Picks',
      '4★ & Up',
      'SSD',
      'AMD',
      'Intel',
      'HP',
      'Lenovo',
      'Dell',
      'ASUS',
      'Acer',
      'MSI',
      'New',
      '250 - 499 GB',
      '500 - 999 GB',
      '1 TB & above',
      'NVIDIA',
    ];
  }

  @override
  void initState() {
    super.initState();
    _isPrimeOnly = widget.initialIsPrime;
    _selectedFilters = List.from(widget.initialSelectedFilters);
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  void _applyAndReturn() {
    Navigator.pop(context, {
      'isPrime': _isPrimeOnly,
      'selectedFilters': _selectedFilters,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sub-Header Title Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE3E6E6)),

          // Main Sidebar + Filter Grid
          Expanded(
            child: Row(
              children: [
                // Left Navigation Sidebar
                Container(
                  width: 120,
                  color: const Color(0xFFF7F8F8),
                  child: ListView.builder(
                    itemCount: _sidebarCategories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF007185)
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            _sidebarCategories[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF007185)
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFE3E6E6),
                ),

                // Right Filter Options Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search filters and brands',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black54,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Suggested Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Prime Toggle Switch
                        Row(
                          children: [
                            const Text(
                              '✓prime',
                              style: TextStyle(
                                color: Color(0xFF00A8E1),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Switch(
                              value: _isPrimeOnly,
                              activeColor: const Color(0xFF007185),
                              onChanged: (val) {
                                setState(() {
                                  _isPrimeOnly = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0xFFE3E6E6)),

                        // Chips Grid
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: _filterOptions.map((filter) {
                            final isSelected =
                                _selectedFilters.contains(filter);
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (filter == '4★ & Up') ...[
                                    const Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Color(0xFFDE7921),
                                    ),
                                    const SizedBox(width: 2),
                                  ],
                                  Text(
                                    filter,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? const Color(0xFF007185)
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (_) => _toggleFilter(filter),
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFFE2F3F5),
                              checkmarkColor: const Color(0xFF007185),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF007185)
                                    : const Color(0xFFD5D9D9),
                                width: isSelected ? 1.5 : 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: double.infinity,
              color: Colors.white,
              child: ElevatedButton(
                onPressed: _applyAndReturn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD814),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _selectedFilters.isEmpty && !_isPrimeOnly
                      ? 'Show Results'
                      : 'Show Results (${_selectedFilters.length + (_isPrimeOnly ? 1 : 0)} selected)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
