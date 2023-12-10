import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Import JSON codec

class DishesScreen extends StatelessWidget {
  DishesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference menus = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('menus');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: menus.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              // Assuming 'menu' is a field within the document that contains an array
// And that you're trying to access the first 'data' array within it
              Map<String, dynamic> menuData =
                  data['menu']['data'][0] as Map<String, dynamic>;

// Assuming 'content' is an array within the 'data' field of 'menu'
// And that 'text' is an array within the first element of 'content'
// And 'annotations' is an array within the first element of 'text'
              String weekMenuString =
                  menuData['content'][0]['text']['value'] as String;

              // Parse the string to get the actual JSON object
              var weekMenu = json.decode(weekMenuString);

              return Column(
                children: weekMenu['week_menu'].map<Widget>((dayData) {
                  var day = dayData['day'];
                  var meals = dayData['meals'];

                  return ExpansionTile(
                    title: Text(day),
                    children: meals.map<Widget>((mealData) {
                      return ListTile(
                        title: Text(mealData['recipe']),
                        subtitle: Text(mealData['meal']),
                        // Implement your logic to display ingredients here
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
