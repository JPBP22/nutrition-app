import 'package:flutter/material.dart';
import 'auth.dart'; // Importing the authentication handling class.
import '../screens/export_screens.dart'; // Importing screens used in the application.

// StatefulWidget WidgetTree to handle dynamic rendering based on authentication state.
class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    // Using StreamBuilder to build UI based on the stream of authentication state changes.
    return StreamBuilder(
        stream: Auth()
            .authStateChanges, // Listening to authentication state changes.
        builder: (context, snapshot) {
          // Conditionally returning a widget based on the authentication state.
          if (snapshot.hasData) {
            // If the snapshot contains user data (i.e., the user is authenticated),
            // then return a different page (e.g., HomePage or Dashboard).
            return LoginPage();
          } else {
            // If the snapshot does not contain user data (i.e., the user is not authenticated),
            // then return the LoginPage.
            return const LoginPage();
          }
        });
  }
}
