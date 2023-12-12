import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importing the Provider package for state management.
import 'package:firebase_core/firebase_core.dart'; // Importing Firebase core package for Firebase initialization.
import 'models/models.dart'; // Importing the models used in the application.
import 'navigation/app_router.dart'; // Importing the app router for navigation.
import 'components/components.dart'; // Importing the components used in the application.

// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensuring that Flutter widgets are initialized.
  await Firebase.initializeApp(); // Initializing Firebase.
  final appStateManager =
      AppStateManager(); // Creating an instance of AppStateManager.
  await appStateManager.initializeApp(); // Initializing the application state.
  runApp(
    ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: NutriApp(
          appStateManager: appStateManager,
        )),
  ); // Running the NutriApp widget.
}

// StatefulWidget representing the NutriApp.
class NutriApp extends StatefulWidget {
  final AppStateManager
      appStateManager; // AppStateManager instance for managing app state.

  const NutriApp({super.key, required this.appStateManager});

  @override
  NutriAppState createState() => NutriAppState();
}

// State class for NutriApp.
class NutriAppState extends State<NutriApp> {
  // Initializing the AppRouter.
  late final _appRouter = AppRouter(
    widget.appStateManager,
  );

  @override
  Widget build(BuildContext context) {
    // Using the ThemeNotifier to get the current theme.
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // Using MultiProvider for state management across the app.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => widget.appStateManager,
        ),
        // Additional providers can be added here.
      ],
      child: Builder(
        builder: (context) {
          final router = _appRouter.router;
          // MaterialApp.router for integrating the router with the app's navigation.
          return MaterialApp.router(
            theme:
                themeNotifier.currentTheme, // Get the current theme of the app.
            title: 'NutriApp', // Setting the app title.
            // Setting up the router for navigation.
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            routerDelegate: router.routerDelegate,
          );
        },
      ),
    );
  }
}
