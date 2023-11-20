import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home.dart';
import 'screens/export_screens.dart';


void main() {
  runApp(const Fooderlich());
}

class Fooderlich extends StatelessWidget {
  const Fooderlich({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light();
    return MaterialApp(
      theme: theme,
      title: 'Fooderlich',
      home: const Home()
      );
  }
}
