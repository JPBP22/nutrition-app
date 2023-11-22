import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home.dart';

void main() {
  runApp(const NutriApp());
}

class NutriApp extends StatelessWidget {
  const NutriApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light();
    return MaterialApp(theme: theme, title: 'NutriApp', home: const Home());
  }
}
