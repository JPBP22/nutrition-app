import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/export_screens.dart';
import '../models/models.dart';
import '../widget_tree.dart';

class AppRouter {
  final AppStateManager appStateManager;
  //final ProfileManager profileManager;
  //final GroceryManager groceryManager;

  AppRouter(
    this.appStateManager,
    // this.profileManager,
    // this.groceryManager,
  );

  late final router = GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: appStateManager,
      initialLocation: '/login',
      routes: [
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const WidgetTree(),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) {
            return const ProfileScreen();
          },
        ),
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
      redirect: (context, state) {
        final loggedIn = appStateManager.isLoggedIn;
        final logginIn = state.subloc == '/login';
        if (!loggedIn) return logginIn ? null : '/login';
        print('Redirect: loggedIn=$loggedIn, logginIn=$logginIn');

        if (logginIn) return '/${NutriAppTab.weeklyMenu}';

        return null;
      });
}
