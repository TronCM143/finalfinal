import 'package:flutter/material.dart';
import 'package:mapa/components/auth_page.dart';
import 'package:mapa/map.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthPage()
    );
  }
}
