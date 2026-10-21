import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/wishlist_provider.dart';
import 'package:flutter_application_1/router.dart';
import 'package:flutter_application_1/pages/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userProvider = UserProvider();
  await userProvider.loadFromStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProxyProvider<UserProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (context, user, cart) {
            final cartProvider = cart ?? CartProvider();
            if (user.isLoggedIn && user.token != null) {
              cartProvider.fetchCart(user.token!);
            } else {
              cartProvider.clear();
            }
            return cartProvider;
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (context, user, wishlist) {
            final wishlistProvider = wishlist ?? WishlistProvider();
            if (user.isLoggedIn && user.token != null) {
              wishlistProvider.fetchWishlist(user.token!);
            } else {
              wishlistProvider.clear();
            }
            return wishlistProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );

  userProvider.validateSession();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amazon Clone',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: GlobalVariables.secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: GlobalVariables.secondaryColor,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: GlobalVariables.secondaryColor,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: const MainLayoutScreen(),
    );
  }
}
