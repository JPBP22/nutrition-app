import 'package:flutter/material.dart';
import '../components/openai_chat_widget.dart'; // Importing the OpenAI chat widget.
import '../app_theme.dart'; // Importing the app's theme settings.

// The main function, which is the entry point of the Flutter application.
void main() {
  runApp(GptNutritionScreen()); // Running the GptNutritionScreen widget.
}

// GptNutritionScreen is a stateless widget, meaning its properties are immutable.
class GptNutritionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OpenAI Chat', // Setting the title of the application.
      theme: AppTheme.dark(), // Applying a dark theme to the application.
      home:
          OpenAIChatWidget(), // Setting OpenAIChatWidget as the home screen of the app.
    );
  }
}
