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
      CollectionReference media = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('media');

      if (_selectedImage != null) {
        // Upload image file to Firebase Storage
        var imageName = DateTime.now().millisecondsSinceEpoch.toString();
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/$userId/$imageName.jpg');
        var uploadTask = storageRef.putFile(_selectedImage!);
        var downloadUrl =
            await uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());

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

  // Function to get the user's profile picture URL from Firestore.
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

  // Function to request camera permission
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (status.isDenied) {
      print('Camera permission was denied');
    }
  }

  // Function to get the user's data from Firestore.
  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    } else {
      throw Exception('User is not logged in');
    }
  }

  // Function to sign out the user.
  Future<void> signOut() async {
    await Auth().signOut();
  }

  // Function to build the sign out button.
  Widget _signOutButton(BuildContext context) {
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
    // Setting the screen height and width using MediaQuery to get dimensions of the device screen.
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    // Building the main widget of the ProfileScreen.
    return Scaffold(
      body: SingleChildScrollView(
        // Using SingleChildScrollView to make the screen scrollable.
        child: Container(
          alignment: Alignment.topCenter,
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .start, // Aligning children to the start of the column.
            children: [
              // A Row widget to contain the back button.
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.go(
                          '/home'); // Navigating to the home screen when the button is pressed.
                    },
                  ),
                ],
              ),
              // GestureDetector to handle the tap action for profile picture update.
              GestureDetector(
                onTap: () async {
                  pickUploadProfilePic(); // Calling method to pick and upload a profile picture.
                },
                child: FutureBuilder<String>(
                  future:
                      _userPhotoFuture, // Future to fetch the user's profile photo URL.
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Displaying a loading spinner while waiting.
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Icon(Icons
                          .error); // Displaying an error icon if there's an error.
                    } else {
                      // Displaying the profile picture or a default icon if there's no picture.
                      return (snapshot.data == null || snapshot.data!.isEmpty)
                          ? // Displaying a default icon if no profile picture is available.
                          Container(
                              margin: const EdgeInsets.only(
                                  top: 5, left: 40, right: 40, bottom: 20),
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
                          : // Displaying the actual profile picture if available.
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, left: 40, right: 40, bottom: 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  profilePicLink,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.fill,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    print('Failed to load image: $exception');
                                    return const Text(
                                        'Failed to load image'); // Displaying an error message if the image fails to load.
                                  },
                                ),
                              ),
                            );
                    }
                  },
                ),
              ),
              // FutureBuilder to fetch and display the user's data.
              FutureBuilder<DocumentSnapshot>(
                future: getUserData(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Displaying a loading spinner while waiting.
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error: ${snapshot.error}'); // Displaying an error message if there's an error.
                  } else if (snapshot.hasData) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        Text(
                          data['username'], // Displaying the username.
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          FirebaseAuth.instance.currentUser!
                              .email!, // Displaying the user's email.
                          style:
                              const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        _signOutButton(context) // Displaying a sign-out button.
                      ],
                    );
                  } else {
                    return const Text(
                        'No data'); // Displaying a message if no data is available.
                  }
                },
              ),
              const SizedBox(height: 20), // Adding spacing at the bottom.
            ],
          ),
        ),
      ),
    );
  }
}
