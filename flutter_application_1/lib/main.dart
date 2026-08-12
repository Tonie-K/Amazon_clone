import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/bottom_bar.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/features/auth/screens/auth_screen.dart';
import 'package:flutter_application_1/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const AuthScreen(),
    );
  }
}
