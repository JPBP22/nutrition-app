import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'package:provider/provider.dart';
import '../models/app_state_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage;
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPasswordController  = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void clearTextFields() {
  _emailController.clear();
  _passwordController.clear();
  _usernameController.clear();
  _confirmPasswordController.clear();
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
    setState(() {
      errorMessage = "Passwords do not match.";
    });
    return;
  }
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
      CollectionReference users = FirebaseFirestore.instance.collection('users');
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
        errorMessage = e.message;
      });
    }
    }
  }

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

  Widget _textFieldPassword(
      String title,
      TextEditingController controller,
    ){
  return TextField(
    controller: _passwordController,
    decoration: const InputDecoration(
      labelText: 'Enter Password',
      border: OutlineInputBorder(),
    ),
    obscureText: true,
  );
  }

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

  Widget _textFieldConfirmPassword(
    String title,
    TextEditingController controller,
  ){
  return TextField(
    controller: _confirmPasswordController,
    decoration: const InputDecoration(
      labelText: 'Confirm Password',
      border: OutlineInputBorder(),
    ),
    obscureText: true,
  );
  }

  void _showError(String errorMessage) {
  SchedulerBinding.instance!.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$errorMessage'),
        backgroundColor: Colors.green,
      ),
    );
  });
  }

  Widget _errorMessage() {
  if (errorMessage != null && errorMessage != '') {
    _showError(errorMessage!);
  }
  return Container();
  }

  Widget _submitButton() {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: Colors.green, // background color
      onPrimary: Colors.white, // text color
      minimumSize: Size(200, 50), // size of the button
    ),
    onPressed: () async {
      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
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
            errorMessage = e.message;
          });
        }
      }
      clearTextFields();
    },
    child: Text(isLogin ? 'Login' : 'Create Account'),
  );
}

  Widget _loginOrRegisterButton(){
    return TextButton(
       style: TextButton.styleFrom(
      primary: isLogin ? Colors.green : Colors.green, // text color
    ),
      onPressed: (){
        setState(() {
          isLogin = !isLogin;
           errorMessage = null;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
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
              borderRadius: BorderRadius.circular(20.0), // adjust the radius as needed
              child: Image(
                image: AssetImage(
                  'lib/assets/logo.jpeg',
                ),
                width: 200, // adjust the width as needed
                height: 200, // adjust the height as needed
                fit: BoxFit.cover, // this makes the image cover the entire space of the ClipRRect
              ),
              ),
              SizedBox(height: 40),
              _textFieldEmail('Email', _emailController),
              SizedBox(height: 20),
              _textFieldPassword('Password', _passwordController),
              SizedBox(height: 10),
              if (!isLogin) ...[
                _textFieldConfirmPassword('Confirm Password', _confirmPasswordController),
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