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

  final List<Widget> pages = const [
    HomePage(),
    AccountScreen(),
    CartPage(),
    MenuPage(),
  ];

  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.home_outlined, label: 'Home'),
    _NavItemData(icon: Icons.person_outline, label: 'You'),
    _NavItemData(icon: Icons.shopping_cart_outlined, label: 'Cart'),
    _NavItemData(icon: Icons.menu, label: 'Browse'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: GlobalVariables.backgroundColor,
            border: Border(
              top: BorderSide(color: Color(0xFFDDDDDD), width: 1),
            )),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) {
                  final item = _navItems[index];
                  final isSelected = index == myCurrentIndex;

                  return Expanded(
                      child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => setState(() => myCurrentIndex = index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 3,
                          width: 32,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Icon(
                          item.icon,
                          size: 26,
                          color: Colors.black,
                        ),
                        Text(item.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ))
                      ],
                    ),
                  ));
                },
              ),
            ),
          ),
        ),
      ),
      body: pages[myCurrentIndex],
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.label,
  });
}
