import 'package:flutter/material.dart';

class SiteBackground extends StatelessWidget {
  const SiteBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/IMG-20241017-WA0109.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        const ColoredBox(color: Color(0x66000000)),
        child,
      ],
    );
  }
}
