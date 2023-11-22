// Importing necessary packages and files
import 'package:flutter/material.dart';
import 'package:nutri_app/components/custom_icons_icons.dart';
import 'screens/export_screens.dart';

// Home widget which is a StatefulWidget
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // Creating the state for Home widget
  HomeState createState() => HomeState();
}

// State class for Home widget
class HomeState extends State<Home> {
  // Variable to keep track of selected index in BottomNavigationBar
  int _selectedIndex = 0;

  // List of pages to display when a BottomNavigationBarItem is selected
  static List<Widget> pages = <Widget>[
    const ExploreScreen(),
    const DishesScreen(),
    const GptNutritionScreen(),
  ];

  // Function to handle item taps in the BottomNavigationBar
  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  // Building the widget
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NutriApp',
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      // Displaying the selected page
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).textSelectionTheme.selectionColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining_outlined),
            label: 'Dishes',
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.gpt_logo),
            label: 'Ask GPT',
          ),
        ],
        // Setting the current index
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
