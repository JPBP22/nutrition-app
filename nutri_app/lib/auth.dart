import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication package.

// Class for handling authentication tasks.
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth
      .instance; // Instance of FirebaseAuth for accessing authentication functionalities.

  // Getter to retrieve the current user.
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream to listen for authentication state changes (login, logout).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Method for signing in with email and password.
  Future<void> signInWithEmailAndPassword({
    required String email, // Email parameter required for sign-in.
    required String password, // Password parameter required for sign-in.
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Method for creating a new user account with email and password.
  Future<void> createUserWithEmailAndPassword({
    required String email, // Email parameter required for account creation.
    required String
        password, // Password parameter required for account creation.
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Method for signing out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
