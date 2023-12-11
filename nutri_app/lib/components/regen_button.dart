import 'package:flutter/material.dart'; // Importing material design package for Flutter UI components.

// Declaration of RegenButton, a stateless widget which means its properties won't change over time.
class RegenButton extends StatelessWidget {
  // Declaration of a VoidCallback, which is a function with no parameters and no return value.
  // This callback is triggered when the button is pressed.
  final VoidCallback onRegenerate;

  // Constructor for RegenButton. It takes a 'key' for identifying the widget in the widget tree (optional)
  // and a 'onRegenerate' callback which is required.
  const RegenButton({Key? key, required this.onRegenerate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Building the UI for the button.
    return ElevatedButton(
      onPressed:
          onRegenerate, // Assigning the onRegenerate callback to be triggered on button press.
      child: Text('Regenerate Menu'), // Text displayed on the button.
    );
  }
}
