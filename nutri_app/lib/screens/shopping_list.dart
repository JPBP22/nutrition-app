import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database for data storage
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/scheduler.dart'; // Scheduler for timing

// Stateless widget for displaying a shopping list
class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  // Function to display a notification when an item is deleted
  void _deleteItemNotifier(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from the shopping list successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetching the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;
    // Reference to the user's shopping list in Firestore
    CollectionReference shoppingList = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shopping_list');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Listening to the shopping list collection for real-time updates
        stream: shoppingList.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // Error handling
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            // Placeholder when the shopping list is empty
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                  Text('Your shopping list is empty',
                      style: TextStyle(color: Colors.grey, fontSize: 20)),
                ],
              ),
            );
          }

          // Building a list of items from the shopping list
          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String ingredient = data['ingredient'];
              String quantity = data['quantity'];

              return ListTile(
                title: Text('$ingredient'),
                subtitle: Text('Quantity: $quantity'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    // Deleting an item and showing a notification
                    await document.reference.delete();
                    _deleteItemNotifier(context);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
