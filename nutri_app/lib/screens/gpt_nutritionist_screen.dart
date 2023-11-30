import 'package:flutter/material.dart';
import '../components/openai_chat_widget.dart';
import '../app_theme.dart';

void main() {
  runApp(GptNutritionScreen());
}

class GptNutritionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OpenAI Chat',
      theme: AppTheme.dark(),
      home: OpenAIChatWidget(),
    );
  }
}
