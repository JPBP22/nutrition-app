import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'models/models.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appStateManager = AppStateManager();
  await appStateManager.initializeApp();
  runApp(NutriApp(appStateManager: appStateManager));
}

class NutriApp extends StatefulWidget {
  final AppStateManager appStateManager;

  const NutriApp({super.key, required this.appStateManager});

  @override
  NutriAppState createState() => NutriAppState();
}

class NutriAppState extends State<NutriApp> {
  // late final _groceryManager = GroceryManager();
  // late final _profileManager = ProfileManager();
  late final _appRouter = AppRouter(
    widget.appStateManager,
    // _profileManager,
    // _groceryManager,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => widget.appStateManager,
        ),
      ],
      child: Builder(
        builder: (context) {
          // TODO: Replace with Router
          final router = _appRouter.router;
          return MaterialApp.router(
            theme: AppTheme.dark(),
            title: 'NutriApp',
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            routerDelegate: router.routerDelegate,
          );
        },
      ),
    );
  }
}
