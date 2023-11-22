import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'models/models.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appStateManager = AppStateManager();
  await appStateManager.initializeApp();
  runApp(Fooderlich(appStateManager: appStateManager));
}

class Fooderlich extends StatefulWidget {
  final AppStateManager appStateManager;

  const Fooderlich({
    super.key,
    required this.appStateManager});

  @override
  FooderlichState createState() => FooderlichState();
}

class FooderlichState extends State<Fooderlich> {
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
            title: 'Fooderlich',
            routeInformationParser: router.routeInformationParser,
            routeInformationProvider: router.routeInformationProvider,
            routerDelegate: router.routerDelegate,
          );
        },
      ),
    );
  }
}

