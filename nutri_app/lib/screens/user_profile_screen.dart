import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';  
import '../models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

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
  File? _selectedImage;

  late Future<String> _userPhotoFuture;

  @override
  void initState() {
    super.initState();
    _userPhotoFuture = getUserPhoto();
  }

  Future<String> pickUploadProfilePic() async {
    await requestCameraPermission();
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // Update _selectedImage here
      });

      String userId = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference media = FirebaseFirestore.instance.collection('users').doc(userId).collection('media');

      if (_selectedImage != null) {
        // Upload image file to Firebase Storage
        var imageName = DateTime.now().millisecondsSinceEpoch.toString();
        var storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId/$imageName.jpg');
        var uploadTask = storageRef.putFile(_selectedImage!);
        var downloadUrl = await uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());

        // Delete the old image from Firebase Storage
        if (profilePicLink.isNotEmpty) {
          var oldImageRef = FirebaseStorage.instance.refFromURL(profilePicLink);
          await oldImageRef.delete();
        }
        // Update the document with the new image reference
        var userDoc = await media.doc(userId).get();
        if (userDoc.exists) {
          await userDoc.reference.update({
            'profile_pic_url': downloadUrl.toString(),
          });
        } else {
          await media.doc(userId).set({
            'profile_pic_url': downloadUrl.toString(),
          });
        }

        // Update profilePicLink with the new URL
        setState(() {
          profilePicLink = downloadUrl.toString();
        });

        print(downloadUrl.toString());

        return downloadUrl.toString();
      } else {
        throw Exception('No image selected');
      }
    }
    return "";  
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
    
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isDenied) {
      print('Camera permission was denied');
    }
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
    icon: const Icon(Icons.logout),
    label: const Text('Logout'),
    onPressed: () async {
      Provider.of<AppStateManager>(context, listen: false).logout();
      await signOut();
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
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Center children horizontally
              children: [
                Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.go('/home');
                  },
                ),
              ],
            ),
                GestureDetector(
                onTap: () async {
                  pickUploadProfilePic(); // Call pickUploadProfilePic when the GestureDetector is tapped
                },
                child: FutureBuilder<String>(
                  future: _userPhotoFuture,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show a loading spinner while waiting for the future to complete
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Icon(Icons.error); // Show an error icon if the future completes with an error
                    } else {
                      return (snapshot.data == null || snapshot.data!.isEmpty)
                    ? Container(
                        margin: const EdgeInsets.only(top: 5, left: 40, right: 40, bottom: 20),
                        height: 120,
                        width: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        ),
                      )
                    : Padding(
                      padding: const EdgeInsets.only(top: 5, left: 40, right: 40, bottom: 20),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            profilePicLink,
                            height: 120,
                            width: 120,
                            fit: BoxFit.fill,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              print('Failed to load image: $exception');
                              print('Loading image from: $profilePicLink');
                              return const Text('Failed to load image');
                            },
                          ),
                        ),
                    );
                    }
                    }
                ),
              ),
                FutureBuilder<DocumentSnapshot>(
                  future: getUserData(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
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
                      return const Text('No data');
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