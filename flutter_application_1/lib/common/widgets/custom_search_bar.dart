import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool showMic;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.hintText = 'Search Amazon.in',
    this.showMic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            controller: controller,
            constraints: const BoxConstraints(maxHeight: 46, minHeight: 40),
            hintText: hintText,
            leading: const Icon(
              Icons.search,
              size: 32,
            ),
            trailing: [
              IconButton(
                icon: const Icon(Icons.camera_enhance_outlined),
                onPressed: () {},
              ),
              if (showMic)
                IconButton(
                  icon: const Icon(Icons.mic_none_outlined),
                  onPressed: () {},
                ),
            ],
            elevation: const WidgetStatePropertyAll(0),
            side: const WidgetStatePropertyAll(
              BorderSide(
                color: Color(0xFF78909C),
                width: 2,
              ),
            ),
            shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(
          width: 0,
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () {},
        )
      ],
    );
  }
}
