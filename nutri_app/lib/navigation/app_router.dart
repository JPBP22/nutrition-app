import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/export_screens.dart';
import '../models/models.dart';

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
        name:'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        ),
      GoRoute(
        name: 'home',
        path: '/:tab',
        builder: (context, state){
          final tab = int.tryParse(state.params['tab'] ?? '') ?? 0;
          return Home(key: state.pageKey, currentTab: tab);
        },
        routes: [
                GoRoute(
                  name: 'iewebpage',
                  path: 'iewebpage',
                  builder: (context, state) => const WebViewScreen(),
          )
      ]),
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

      if(logginIn) return '${NutriAppTab.explore}';

      return null;
    }

  );
}
