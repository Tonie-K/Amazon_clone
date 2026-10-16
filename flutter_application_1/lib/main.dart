import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/providers/user_provider.dart';
import 'package:flutter_application_1/router.dart';
import 'package:flutter_application_1/pages/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userProvider = UserProvider();
  await userProvider.loadFromStorage();

  runApp(
    ChangeNotifierProvider.value(
      value: userProvider,
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
      title: 'Flutter Demo',
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
          ))),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: const MainLayoutScreen(),
    );
  }
}
