import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_variables.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text("This is the appbar."),
        ),
        body: Column(
          children: [
            const Center(
              child: Text('Home Page'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('click'),
            ),
          ],
        ),
      ),
    );
  }
}
