import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_app_bar.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomAppBar(),
      ),
      body: Center(
        child: Text('This is the cart page'),
      ),
    );
  }
}
