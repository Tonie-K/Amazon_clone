import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/search_screen.dart';

class CustomSearchBar extends StatelessWidget {
  final bool isSearchPage;

  const CustomSearchBar({
    super.key,
    this.isSearchPage = false,
  });

  void _navigateToSearchScreen(BuildContext context, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      Navigator.pushNamed(
        context,
        SearchScreen.routeName,
        arguments: trimmedQuery,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSearchPage)
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        Expanded(
          child: SearchBar(
            constraints: const BoxConstraints(maxHeight: 46, minHeight: 40),
            hintText: 'Search Amazon.in',
            leading: const Icon(
              Icons.search,
              size: 28,
            ),
            trailing: [
              IconButton(
                icon: const Icon(Icons.photo_camera_outlined),
                onPressed: () {},
              ),
            ],
            elevation: const WidgetStatePropertyAll(0),
            side: const WidgetStatePropertyAll(
              BorderSide(
                color: Color(0xFF78909C),
                width: 2,
              ),
            ),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
              ),
            ),
            onSubmitted: (value) => _navigateToSearchScreen(context, value),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () {},
        )
      ],
    );
  }
}
