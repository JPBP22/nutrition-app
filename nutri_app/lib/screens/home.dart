import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_app/components/custom_icons_icons.dart';
import '../models/app_state_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'export_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    const ShoppingList(),
    const WeeklyMenu(),
    GptNutritionScreen(),
    const ProfileScreen(),
  ];

  static List<String> pageTitles = <String>[
    'Shopping List',
    'Weekly Menu',
    'GPT Nutritionist',
    'Profile',
  ];

  late Future<String> _userPhotoFuture;

  @override
  void initState() {
    super.initState();
    _userPhotoFuture = getUserPhoto();
  }

  final User? user = Auth().currentUser;
  String profilePicLink = "";

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<String> getUserPhoto() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot mediaSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('media')
          .get();

      if (mediaSnapshot.docs.isNotEmpty) {
        var mediaData = mediaSnapshot.docs.first.data() as Map<String, dynamic>;
        if (mediaData['profile_pic_url'] != null) {
          print('Got profile_pic_url');
          if (mounted) {
            setState(() {
              profilePicLink = mediaData['profile_pic_url'];
            });
          }
        }
      }
    }
    return profilePicLink;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[widget.currentTab],
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[profileButton(widget.currentTab, context)],
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
        future: _userPhotoFuture,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading spinner while waiting for the photo
          } else if (snapshot.hasError) {
            return Container(); // Show an empty Container if an error occurred
          } else {
            return GestureDetector(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: snapshot.data!.isEmpty
                    ? null
                    : NetworkImage(
                        snapshot.data!), // Load the profile photo if it exists
              ),
              onTap: () {
                // Navigate to profile screen
                context.go('/profile');
              },
            );
          }
        },
      ),
    );
  }
}
