import 'package:flutter/material.dart';

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, left: 8.0, right: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Icon(icon, size: 30, color: const Color(0xFF333333)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0F1111),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
