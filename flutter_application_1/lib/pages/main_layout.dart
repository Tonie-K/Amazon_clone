import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/common/widgets/custom_search_bar.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/pages/account_screen.dart';
import 'package:flutter_application_1/pages/cart_page.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/menu_page.dart';
import 'package:flutter_application_1/pages/product_detail_screen.dart';
import 'package:flutter_application_1/pages/wallet_page.dart';
import 'package:flutter_application_1/pages/search_screen.dart';
import 'package:flutter_application_1/pages/wishlist_page.dart';

class _ShellObserver extends NavigatorObserver {
  final void Function(int delta) onDepthChange;
  final void Function(String query) onSearchRoute;

  _ShellObserver({required this.onDepthChange, required this.onSearchRoute});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) onDepthChange(1);
    final args = route.settings.arguments;
    if (route.settings.name == SearchScreen.routeName && args is String) {
      onSearchRoute(args);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onDepthChange(-1);
    final prevArgs = previousRoute?.settings.arguments;
    final backOnSearch =
        previousRoute?.settings.name == SearchScreen.routeName &&
            prevArgs is String;
    onSearchRoute(backOnSearch ? prevArgs : '');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onDepthChange(-1);
  }
}

class MainLayoutScreen extends StatefulWidget {
  static const String routeName = '/main-layout';

  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<int> _depth = ValueNotifier<int>(0);

  late final _ShellObserver _observer = _ShellObserver(
    onDepthChange: (delta) {
      final next = _depth.value + delta;
      _depth.value = next < 0 ? 0 : next;
    },
    onSearchRoute: (query) => _searchController.text = query,
  );

  final List<Widget> _pages = const [
    HomePage(),
    AccountScreen(),
    WalletPage(),
    CartPage(),
    MenuPage(),
  ];

  @override
  void dispose() {
    _tabIndex.dispose();
    _depth.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    _navKey.currentState!.pushNamed(SearchScreen.routeName, arguments: q);
  }

  void _onTabTap(int index) {
    _navKey.currentState?.popUntil((route) => route.isFirst);
    _tabIndex.value = index;
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SearchScreen.routeName:
        final query = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SearchScreen(searchQuery: query),
        );
      case ProductDetailScreen.routeName:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailScreen(product: product),
        );
      case WishlistPage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WishlistPage(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ValueListenableBuilder<int>(
            valueListenable: _tabIndex,
            builder: (_, index, __) => IndexedStack(
              index: index,
              children: _pages,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final nav = _navKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else if (_tabIndex.value != 0) {
          _tabIndex.value = 0;
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: ListenableBuilder(
          listenable: Listenable.merge([_tabIndex, _depth]),
          builder: (context, _) {
            final showHeader = _tabIndex.value != 0 || _depth.value > 0;
            final canGoBack = _depth.value > 0;

            return Column(
              children: [
                showHeader
                    ? Container(
                        color: GlobalVariables.secondaryColor,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                            child: Row(
                              children: [
                                if (canGoBack)
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.black),
                                    onPressed: () {
                                      _navKey.currentState?.pop();
                                    },
                                  ),
                                Expanded(
                                  child: CustomSearchBar(
                                    controller: _searchController,
                                    onSubmitted: _onSearch,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: showHeader,
                    child: Navigator(
                      key: _navKey,
                      observers: [_observer],
                      onGenerateRoute: _onGenerateRoute,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _tabIndex,
          builder: (_, index, __) => BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: const Color(0xFF008397),
            unselectedItemColor: Colors.black87,
            type: BottomNavigationBarType.fixed,
            onTap: _onTabTap,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'You',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Menu',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
