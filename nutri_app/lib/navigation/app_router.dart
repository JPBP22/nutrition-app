import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/export_screens.dart';
import '../models/models.dart';
import '../widget_tree.dart';

class AppRouter {
  final AppStateManager appStateManager;
  // Additional managers can be declared here for handling other application states.

  // Constructor for AppRouter. It takes an AppStateManager.
  AppRouter(this.appStateManager);

  // Declaration and initialization of the router using GoRouter.
  late final router = GoRouter(
      debugLogDiagnostics: true, // Enables logging for diagnostics.
      refreshListenable:
          appStateManager, // Listens to AppStateManager for changes in the state.
      initialLocation: '/login', // Sets the initial route of the application.
      routes: [
        // Define the route for the login screen.
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const WidgetTree(),
        ),
        // Define the route for the profile screen.
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) {
            return const ProfileScreen();
          },
        ),
        // Define the route for the home screen with dynamic tab navigation.
        GoRoute(
          name: 'home',
          path: '/:tab',
          builder: (context, state) {
            final tab = int.tryParse(state.params['tab'] ?? '') ?? 0;
            print('Navigating to tab: $tab');
            return Home(key: state.pageKey, currentTab: tab);
          },
        ),
      ],
      // Error page builder for handling navigation errors.
      errorPageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            body: Center(
              child: Text(state.error.toString()),
            ),
          ),
        );
      },
      // Redirect logic based on the user's login status.
      redirect: (context, state) {
        final loggedIn = appStateManager.isLoggedIn;
        final logginIn = state.subloc == '/login';
        if (!loggedIn) return logginIn ? null : '/login';
        print('Redirect: loggedIn=$loggedIn, logginIn=$logginIn');

        if (logginIn) return '/${NutriAppTab.weeklyMenu}';

        return null;
      });
}
