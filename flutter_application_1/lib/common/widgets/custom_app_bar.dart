import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_search_bar.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 76,
      titleSpacing: 0,
      title: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CustomSearchBar(),
      ),
    );
  }
}
