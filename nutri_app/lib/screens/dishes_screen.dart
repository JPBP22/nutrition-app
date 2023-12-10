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
              Map<String, dynamic> menuData =
                  data['menu']['data'][0] as Map<String, dynamic>;
              String weekMenuString =
                  menuData['content'][0]['text']['value'] as String;
              var weekMenu = json.decode(weekMenuString);

              return Column(
                children: weekMenu['week_menu'].map<Widget>((dayData) {
                  var day = dayData['day'];
                  var meals = dayData['meals'];

                  return ExpansionTile(
                    title: Text(day),
                    children: meals.map<Widget>((mealData) {
                      return ExpansionTile(
                        // Updated title with meal type and recipe name
                        title: Row(
                          children: [
                            Text(mealData['meal'] + ': '),
                            Expanded(
                              child: Text(
                                mealData['recipe'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        children: mealData['ingredients'] != null
                            ? (mealData['ingredients'] as Map<String, dynamic>)
                                .entries
                                .map<Widget>((entry) {
                                return ListTile(
                                  title: Text("${entry.key}: ${entry.value}"),
                                );
                              }).toList()
                            : [ListTile(title: Text('No ingredients listed'))],
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
