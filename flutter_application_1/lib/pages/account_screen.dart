import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/common/widgets/icons_tile.dart';
import 'package:flutter_application_1/pages/auth_screen.dart';

class AccountScreen extends StatefulWidget {
  static const String routeName = '/account';
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        title: CustomAppBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hello',
                    style: TextStyle(fontSize: 16, color: Color(0xFF565959)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.settings_outlined,
                          color: Color(0xFF0F1111), size: 24),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.asset(
                              'assets/images/flag.png',
                              width: 18,
                              height: 12,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'EN',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to Amazon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0F1111),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Standard Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: GlobalVariables.secondaryColor,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFD5D9D9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Create account',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Standard Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: GlobalVariables.greyBackgroundCOlor,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFD5D9D9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                
                  const IconTile(
                    icon: Icons.published_with_changes_rounded,
                    text: 'Upto ₹100 cashback on your first order',
                  ),
                  const IconTile(
                    icon: Icons.local_shipping_outlined,
                    text: 'Free Delivery on first order – for top categories',
                  ),
                  const IconTile(
                    icon: Icons.assignment_return_outlined,
                    text: 'Easy Returns',
                  ),
                  const IconTile(
                    icon: Icons.payments_outlined,
                    text: 'Pay on Delivery',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
