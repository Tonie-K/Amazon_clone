import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/global_variables.dart';


class BelowAppBar extends StatelessWidget {
  const BelowAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: GlobalVariables.appBarGradient,
      ),
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: RichText(
        text: TextSpan(
          text: 'Hello,',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
          /*children: [
            TextSpan(
              text: user.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22
              ),
            ),
          ]*/
        ),
      )
    );
  }
}