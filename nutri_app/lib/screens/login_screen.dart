import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'package:provider/provider.dart';
import '../models/app_state_manager.dart';

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

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
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
    ) {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
      ),
    );
  }

  Widget _errorMessage(){
    return Text(errorMessage == '' ? '': 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
          try {
            if (isLogin) {
              // Attempt to sign in
              await Auth().signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
            } else {
              // Attempt to create user
              await Auth().createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
            }
            Provider.of<AppStateManager>(context, listen: false)
                .login(_emailController.text, _passwordController.text);
          } on FirebaseAuthException catch (e) {
            setState(() {
              errorMessage = e.message;
            });
          }
        }
      },
      child: Text(isLogin ? 'Login' : 'Create Account'),
    );
  }

  Widget _loginOrRegisterButton(){
    return TextButton(
      onPressed: (){
        setState(() {
          isLogin = !isLogin;
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
              const SizedBox(
                height: 200,
                child: Image(
                  image: AssetImage(
                    'lib/assets/logo.jpeg',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _textFieldEmail('email', _emailController),
              const SizedBox(height: 16),
              _textFieldPassword('password', _passwordController),
              _errorMessage(),
              _submitButton(),
              const SizedBox(height: 16),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  Widget buildButton(BuildContext context) {
    return SizedBox(
      height: 55,
      child: MaterialButton(
        color: rwColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          Provider.of<AppStateManager>(context, listen: false)
              .login('mockUsername', 'mockPassword');
        },
      ),
    );
  }

  Widget buildTextfield(String hintText) {
    return TextField(
      cursorColor: rwColor,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
          ),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(height: 0.5),
      ),
    );
  }
}
*/