import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';

class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  void _deleteItemNotifier(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference shoppingList = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('shopping_list');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: shoppingList.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            // Display the placeholder
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                  Text('Your shopping list is empty', style: TextStyle(color: Colors.grey, fontSize: 20)),
                ],
              ),
            );
          }
          
          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String ingredient = data['ingredient'];
              String quantity = data['quantity'];

          return ListTile(
            title: Text('$ingredient'),
            subtitle: Text('Quantity: $quantity'),
            trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
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