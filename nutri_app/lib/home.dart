import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_icons_icons.dart';
import 'screens/export_screens.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;

  static List<Widget> pages = <Widget>[

    const ExploreScreen(),
    const DishesScreen(),
    const GptNutritionScreen(),

  ];
  void onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //return Consumer<TabManager>(
      //builder: (context, tabManager, child){
        return Scaffold(
        appBar: AppBar(
          title: Text(
            'Fooderlich',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: pages[_selectedIndex], //tabManager.selectedTab
        bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).textSelectionTheme.selectionColor,
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
              label: 'To Buy',
            ),
          ],
        currentIndex: _selectedIndex, //tabManager.selectedTab
        onTap: onItemTapped,
        ),
        );
      }
}
