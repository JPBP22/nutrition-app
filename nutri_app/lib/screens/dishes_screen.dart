import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class DishesScreen extends StatelessWidget {
  const DishesScreen({Key? key}) : super(key: key);

  void _savedItemNotifier(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
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
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference menus = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('menus');
    
    CollectionReference shoppingList = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shopping_list');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: menus.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              Map<String, dynamic> menuData =
                  data['menu']['data'][0] as Map<String, dynamic>;
              String weekMenuString =
                  menuData['content'][0]['text']['value'] as String;
              var weekMenu = json.decode(weekMenuString);

              String menuName = data['name'];
              DateTime createdAt = data['created_at'].toDate();

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.all(16),
                  leading: Icon(Icons.menu_book, color: Colors.blue),
                  title: Text(
                    '$menuName',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Created on ${DateFormat.yMd().format(createdAt)}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  children: weekMenu['week_menu'].map<Widget>((dayData) {
                    var day = dayData['day'];
                    var meals = dayData['meals'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ExpansionTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(day),
                        children: meals.map<Widget>((mealData) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              elevation: 2,
                              child: ListTile(
                                leading: const Icon(Icons.restaurant),
                                title: Text(
                                  '${mealData['meal']}: ${mealData['recipe']}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: mealData['ingredients'] != null
                                      ? (mealData['ingredients'] as Map<String, dynamic>)
                                          .entries
                                          .map<Widget>((entry) {
                                          return ListTile(
                                            title: Text("${entry.key}: ${entry.value}"),
                                            trailing: IconButton(
                                              icon: Icon(Icons.add_shopping_cart),
                                              onPressed: () async {
                                                await shoppingList.add({
                                                  'ingredient': entry.key,
                                                  'quantity': entry.value,
                                                });
                                                _savedItemNotifier(context);
                                              },
                                            ),
                                          );
                                        }).toList()
                                      : [ListTile(title: Text('No ingredients listed'))],
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
          );
        },
      ),
    );
  }
}
