import 'package:flutter/material.dart';

class CardLayout extends StatelessWidget {
  const CardLayout({required this.content, super.key});

  final Widget content;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsetsGeometry.all(16),
        child: content,
      ),
    );
  }
}
