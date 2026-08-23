import "package:flutter/material.dart";
import "package:flutter_application_1/constants/global_variables.dart";
import "package:flutter_application_1/features/account/screens/account_screen.dart";
import "package:flutter_application_1/pages/auth_screen.dart";
import "package:flutter_application_1/pages/cart_page.dart";
import "package:flutter_application_1/pages/home_page.dart";
import "package:flutter_application_1/pages/menu_page.dart";

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int myCurrentIndex = 0;

  List pages = const [
    HomePage(),
    AccountScreen(),
    CartPage(),
    MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: GlobalVariables.backgroundColor,
            border: Border(
              top: BorderSide(color: Color(0xFFDDDDDD), width: 1),
            ),
          ),
          child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: myCurrentIndex,
              onTap: (index) {
                setState(() {
                  myCurrentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_3),
                  label: 'You',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Browse',
                ),
              ]),
        ),
        body: pages[myCurrentIndex]);
  }
}
