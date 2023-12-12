import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_app/components/custom_icons_icons.dart';
import 'package:nutri_app/screens/weekly_menu.dart';
import '../models/app_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'export_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  // Constructor for Home widget, taking the current tab index.
  Home({
    super.key,
    required this.currentTab,
  });

  final int currentTab; // The index of the currently selected tab.

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  // A static list of pages (widgets) for each tab in the app.
  static List<Widget> pages = <Widget>[
    const ShoppingList(),
    const WeeklyMenu(),
    GptNutritionScreen(),
    const ProfileScreen(),
  ];

  // Titles for each of the pages.
  static List<String> pageTitles = <String>[
    'Shopping List',
    'Weekly Menu',
    'GPT Nutritionist',
    'Profile',
  ];

  late Future<String> _userPhotoFuture; // Future to load the user's photo URL.

  @override
  void initState() {
    super.initState();
    _userPhotoFuture =
        getUserPhoto(); // Load user photo URL on widget initialization.
  }

  // User authentication and profile picture management.
  final User? user = Auth().currentUser;
  String profilePicLink = "";

  // Function to sign out the user.
  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<String> getUserPhoto() async {
    User? user = FirebaseAuth.instance
        .currentUser; // Retrieves the current user from Firebase Authentication.

    if (user != null) {
      // If a user is logged in, proceed to fetch their profile photo.
      QuerySnapshot mediaSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('media')
          .get(); // Fetches the 'media' collection data for the current user from Firestore.

      if (mediaSnapshot.docs.isNotEmpty) {
        // Checks if there is at least one document in the 'media' collection.
        var mediaData = mediaSnapshot.docs.first.data()
            as Map<String, dynamic>; // Retrieves the first document's data.
        if (mediaData['profile_pic_url'] != null) {
          // Checks if the 'profile_pic_url' field is present.
          print('Got profile_pic_url');
          if (mounted) {
            setState(() {
              profilePicLink = mediaData[
                  'profile_pic_url']; // Updates the profilePicLink with the URL from Firestore.
            });
          }
        }
      }
    }
    return profilePicLink; // Returns the profile picture URL.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            pageTitles[widget
                .currentTab], // Sets the title of the AppBar based on the current tab.
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        actions: <Widget>[
          profileButton(widget.currentTab, context)
        ], // Adds the profile button to the AppBar.
      ),
      body: IndexedStack(
          index: widget.currentTab,
          children:
              pages), // Displays the widget corresponding to the selected tab.
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context)
            .textSelectionTheme
            .selectionColor, // Sets the color for the selected item in the BottomNavigationBar.
        currentIndex: widget.currentTab, // Sets the currently selected tab.
        onTap: (index) {
          // Handles tab changes.
          Provider.of<AppStateManager>(context, listen: false).goToTab(
              index); // Updates the AppStateManager with the new tab index.
          context.goNamed('home', params: {
            'tab': '$index'
          }); // Navigates to the 'home' route with the new tab index as a parameter.
        },
        items: const [
          // Defines the items in the BottomNavigationBar.
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining_outlined),
            label: 'Weekly Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.gpt_logo),
            label: 'GPT Nutritionist',
          ),
        ],
      ),
    );
  }

  Widget profileButton(int currentTab, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: FutureBuilder<String>(
        future: _userPhotoFuture, // Loads the user's profile photo URL.
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Shows a spinner while the profile photo is loading.
          } else if (snapshot.hasError) {
            return Container(); // Displays an empty container if there's an error loading the photo.
          } else {
            return GestureDetector(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: snapshot.data!.isEmpty
                    ? null
                    : NetworkImage(snapshot
                        .data!), // Displays the user's profile photo if available.
              ),
              onTap: () {
                context.go(
                    '/profile'); // Navigates to the profile screen when the avatar is tapped.
              },
            );
          }
        },
      ),
    );
  }
}
