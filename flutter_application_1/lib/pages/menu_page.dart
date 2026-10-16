import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants/global_variables.dart';
import 'package:flutter_application_1/providers/user_provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shortcuts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              if (user.isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<UserProvider>().logout();
                    },
                    icon: const Icon(Icons.logout, color: Colors.black87),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: GlobalVariables.greyBackgroundCOlor,
                      side: const BorderSide(color: Color(0xFFD5D9D9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else
                const Center(
                  child: Text(
                    'You are currently signed out.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
