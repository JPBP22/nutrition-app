import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

// Declaring the WeeklyMenu widget which is a StatelessWidget.
class WeeklyMenu extends StatelessWidget {
  const WeeklyMenu({Key? key}) : super(key: key);

  // Method to show a notification using a SnackBar after an item is saved.
  void _savedItemNotifier(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item saved to the shopping list successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting the user ID from FirebaseAuth.
    String userId = FirebaseAuth.instance.currentUser!.uid;
    // References to Firestore collections for menus and shopping list.
    CollectionReference menus = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('menus');
    CollectionReference shoppingList = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shopping_list');

    // Asynchronous method to get the username from Firestore.
    Future<String> _getUserName() async {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['username'];
    }

    return FutureBuilder<String>(
      future: _getUserName(), // Future to fetch the username
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Showing a loading indicator while waiting for the username
        }

        // Handling the username data, providing a default value if not available
        String username = snapshot.data ?? 'User';

        // Building the main layout of the WeeklyMenu screen
        return Scaffold(
          body: StreamBuilder<QuerySnapshot>(
            stream: menus
                .snapshots(), // Stream to listen to menu changes in Firestore
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text(
                    'Something went wrong'); // Error handling for the stream
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Showing a loading indicator while the stream is loading
              }

              // Building a list view to display each menu
              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Welcome $username, are you ready to cook? 🍳', // Greeting message with the user's name
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    Map<String, dynamic> menuData =
                        data['menu']['data'][0] as Map<String, dynamic>;
                    String weekMenuString =
                        menuData['content'][0]['text']['value'] as String;
                    var weekMenu = json.decode(
                        weekMenuString); // Decoding the menu data from JSON

                    String menuName = data['name']; // Menu name
                    DateTime createdAt = data['created_at']
                        .toDate(); // Creation date of the menu

                    // Building a card for each menu
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.all(16),
                        leading: Icon(Icons.menu_book,
                            color: Colors.blue), // Menu icon
                        title: Text(
                          '$menuName', // Displaying the menu name
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Created on ${DateFormat.yMd().format(createdAt)}', // Displaying the creation date
                          style: TextStyle(color: Colors.grey),
                        ),
                        children: weekMenu['week_menu'].map<Widget>((dayData) {
                          var day = dayData['day']; // The day of the week
                          var meals =
                              dayData['meals']; // The meals for that day

                          // Inside the StreamBuilder, mapping each day's data to create an ExpansionTile for the day
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ExpansionTile(
                              leading: const Icon(Icons
                                  .calendar_today), // Icon representing a calendar
                              title:
                                  Text(day), // Displaying the day of the week
                              children: meals.map<Widget>((mealData) {
                                // For each meal, creating a card with details
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    elevation: 2,
                                    child: ListTile(
                                      leading: const Icon(Icons
                                          .restaurant), // Icon representing a restaurant or meal
                                      title: Text(
                                        '${mealData['meal']}: ${mealData['recipe']}', // Displaying the meal name and associated recipe
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: mealData['ingredients'] !=
                                                null
                                            ? (mealData['ingredients']
                                                    as Map<String, dynamic>)
                                                .entries
                                                .map<Widget>((entry) {
                                                // Mapping each ingredient to a ListTile
                                                return ListTile(
                                                  title: Text(
                                                      "${entry.key}: ${entry.value}"), // Displaying the ingredient and its quantity
                                                  trailing: IconButton(
                                                    icon: Icon(Icons
                                                        .add_shopping_cart), // Icon representing adding to shopping cart
                                                    onPressed: () async {
                                                      // Adding the ingredient to the user's shopping list in Firestore
                                                      await shoppingList.add({
                                                        'ingredient': entry.key,
                                                        'quantity': entry.value,
                                                      });
                                                      _savedItemNotifier(
                                                          context); // Showing a notification that the item is saved
                                                    },
                                                  ),
                                                );
                                              }).toList()
                                            : [
                                                ListTile(
                                                    title: Text(
                                                        'No ingredients listed'))
                                              ], // Displaying a message if no ingredients are listed
                                      ),
                                      contentPadding: EdgeInsets.all(16),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
