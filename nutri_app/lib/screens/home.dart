import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_app/components/custom_icons_icons.dart';
import '../models/app_state_manager.dart';
import 'explore_screen.dart';
import 'dishes_screen.dart';
import 'gpt_nutritionist_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
    required this.currentTab,
  });

  final int currentTab;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  static List<Widget> pages = <Widget>[
    const ExploreScreen(),
    DishesScreen(menuData: {/* your default menu data here */}), // Ensure proper data is passed
    GptNutritionScreen(),
  ];

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        Provider.of<AppStateManager>(context, listen: false).logout();
        signOut();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NutriApp',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[
          _signOutButton(),        
        ],
      ),
      body: IndexedStack(index: widget.currentTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).textSelectionTheme.selectionColor,
        currentIndex: widget.currentTab,
        onTap: (index) {
          Provider.of<AppStateManager>(context, listen: false).goToTab(index);
          context.goNamed('home', params: {'tab': '$index'});
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining_outlined),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.gpt_logo),
            label: 'GPT Nutritionist',
          ),
        ],
      ),
    );
  }

  Widget profileButton(int currentTab) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        child: const CircleAvatar(
          backgroundColor: Colors.transparent,
        ),
        onTap: () {
          // TODO: Navigate to profile screen
        },
      ),
    );
  }
}
