import 'package:shared_preferences/shared_preferences.dart'; // Importing the shared_preferences package.

class AppCache {
  static const kUser = 'user'; // A constant key to store user login status.

  // Method to invalidate (log out) the user.
  Future<void> invalidate() async {
    final prefs = await SharedPreferences
        .getInstance(); // Getting an instance of SharedPreferences.
    await prefs.setBool(kUser,
        false); // Setting the user login status to false (not logged in).
  }

  // Method to cache (log in) the user.
  Future<void> cacheUser() async {
    final prefs = await SharedPreferences
        .getInstance(); // Getting an instance of SharedPreferences.
    await prefs.setBool(
        kUser, true); // Setting the user login status to true (logged in).
  }

  // Method to check if the user is logged in.
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences
        .getInstance(); // Getting an instance of SharedPreferences.
    return prefs.getBool(kUser) ??
        false; // Retrieving the user login status, defaulting to false if not set.
  }
}
