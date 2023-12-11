import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import '../auth.dart'; // Custom authentication logic
import 'package:provider/provider.dart'; // State management using Provider
import '../models/app_state_manager.dart'; // App state management
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:flutter/scheduler.dart'; // Scheduler for timing

// Defines a stateful widget for the login page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage; // Stores error messages
  bool isLogin = true; // Flag to toggle between login and registration

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message; // Set error message if sign-in fails
      });
    }
  }

  // Clear text fields
  void clearTextFields() {
    _emailController.clear();
    _passwordController.clear();
    _usernameController.clear();
    _confirmPasswordController.clear();
  }

  // Create a new user with email and password
  Future<void> createUserWithEmailAndPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorMessage =
            "Passwords do not match."; // Error if passwords don't match
      });
      return;
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      return users
          .doc(userCredential.user?.uid)
          .set({
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          })
          .then((value) => print("Preferences Saved"))
          .catchError((error) => print("Failed to save preferences: $error"));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message; // Set error message if registration fails
        });
      }
    }
  }

  // Create email text field
  Widget _textFieldEmail(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
      ),
    );
  }

  // Create password text field
  Widget _textFieldPassword(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Enter Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true, // Hides the password
    );
  }

  // Create username text field
  Widget _textFieldUsername(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
      ),
    );
  }

  // Create confirm password text field
  Widget _textFieldConfirmPassword(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: _confirmPasswordController,
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true, // Hides the confirm password
    );
  }

  // Display error message using a SnackBar
  void _showError(String errorMessage) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Widget to display error messages
  Widget _errorMessage() {
    if (errorMessage != null && errorMessage != '') {
      _showError(errorMessage!);
    }
    return Container(); // Empty container if no error
  }

  // Submit button for login/registration
  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.green, // background color
        onPrimary: Colors.white, // text color
        minimumSize: Size(200, 50), // size of the button
      ),
      onPressed: () async {
        if (_emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          try {
            if (isLogin) {
              // Attempt to sign in
              await Auth().signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
              Provider.of<AppStateManager>(context, listen: false)
                  .login(_emailController.text, _passwordController.text);
            } else {
              // Attempt to create user
              await createUserWithEmailAndPassword();
              if (errorMessage == null || errorMessage!.isEmpty) {
                Provider.of<AppStateManager>(context, listen: false)
                    .login(_emailController.text, _passwordController.text);
              }
            }
          } on FirebaseAuthException catch (e) {
            setState(() {
              errorMessage =
                  e.message; // Set error message if authentication fails
            });
          }
        }
        clearTextFields(); // Clear text fields after submission
      },
      child: Text(isLogin
          ? 'Login'
          : 'Create Account'), // Button text changes based on mode
    );
  }

  // Toggle button between login and registration
  Widget _loginOrRegisterButton() {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.green, // text color
      ),
      onPressed: () {
        setState(() {
          isLogin = !isLogin; // Toggle the flag
          errorMessage = null; // Clear error message
        });
      },
      child: Text(isLogin
          ? 'Register instead'
          : 'Login instead'), // Button text changes based on mode
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(top: 44.0),
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20.0), // Radius of the image
                child: Image(
                  image: AssetImage(
                    'lib/assets/logo.jpeg',
                  ),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover, // Image fills the ClipRRect
                ),
              ),
              SizedBox(height: 40),
              _textFieldEmail('Email', _emailController),
              SizedBox(height: 20),
              _textFieldPassword('Password', _passwordController),
              SizedBox(height: 20),
              if (!isLogin) ...[
                // Show additional fields if in registration mode
                _textFieldConfirmPassword(
                    'Confirm Password', _confirmPasswordController),
                SizedBox(height: 20),
                _textFieldUsername('Username', _usernameController),
                SizedBox(height: 20),
              ],
              _errorMessage(),
              SizedBox(height: 20),
              _submitButton(),
              SizedBox(height: 20),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
