import 'package:flutter/material.dart';

class NavigatedScreen extends StatelessWidget {
  const NavigatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigated screen"),
      ),
      body: const Center(
        child: Text("Navigated successfully!!"),
      ),
    );
  }
}
