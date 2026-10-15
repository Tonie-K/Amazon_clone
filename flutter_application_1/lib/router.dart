import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/account_screen.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';
import 'package:flutter_application_1/pages/otp_screen.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );
    case ProductDetailScreen.routeName:
      final product = routeSettings.arguments as Product;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ProductDetailScreen(product: product),
      );
    case AccountScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AccountScreen(),
      );
    case OtpScreen.routeName:
      final email = routeSettings.arguments as String? ?? '';
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => OtpScreen(email: email),
      );

    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Screen does not exist!'),
          ),
        ),
      );
  }
}
