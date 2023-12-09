import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';  
import '../models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String profilePicLink = "";

  Future pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref().child("profilepic.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
       profilePicLink = value;
      });
    });
  }

  Future<DocumentSnapshot> getUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  } else {
    throw Exception('User is not logged in');
  }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _signOutButton(BuildContext context){
    return ElevatedButton.icon(
    icon: Icon(Icons.logout),
    label: Text('Logout'),
    onPressed: () async {
      if (context != null) {
        Provider.of<AppStateManager>(context, listen: false).logout();
        await signOut();
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.green, // background color
        onPrimary: Colors.white, // text color
        minimumSize: Size(200, 50),
      // Add your button styles here
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Center children horizontally
              children: [
                GestureDetector(
                  onTap: () {
                    pickUploadProfilePic();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 20),
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: profilePicLink.isEmpty ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 80,
                      ) : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(profilePicLink),
                      ),
                    ),
                  ),
                FutureBuilder<DocumentSnapshot>(
                  future: getUserData(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Handle the error
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Text(
                            data['username'],
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            FirebaseAuth.instance.currentUser!.email!,
                            style: const TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          _signOutButton(context)
                        ],
                      );
                    } else {
                      // Handle the case when snapshot doesn't have data
                      return Text('No data');
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
      ),
    );
  }
  }