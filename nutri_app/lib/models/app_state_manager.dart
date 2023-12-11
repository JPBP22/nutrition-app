import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart'; // Importing custom models.

// NutriAppTab is a utility class holding constants to represent different tabs in the app.
class NutriAppTab {
  static const int shoppingList = 0;
  static const int weeklyMenu = 1;
  static const int gptNutrition = 2;
  static const int userProfile = 3;
}

// AppStateManager manages the state of the app, including user login and current tab.
class AppStateManager extends ChangeNotifier {
  // Private variable to check if the user is logged in.
  bool _loggedIn = false;
  // Private variable to record the current tab the user is on.
  int _selectedTab = NutriAppTab.shoppingList;
  // Instance of AppCache to store user state in the file system.
  final _appCache = AppCache();

  // Public getter to access the current selected tab.
  int get selectedTab => _selectedTab;

  // Public getters for state properties.
  bool get isLoggedIn => _loggedIn;
  int get getSelectedTab => _selectedTab;

  // Method to initialize the app. Checks if the user is logged in.
  Future<void> initializeApp() async {
    _loggedIn = await _appCache.isUserLoggedIn();
  }

  // Method to handle user login.
  void login(String username, String password) async {
    _loggedIn = true;
    await _appCache.cacheUser(); // Cache the user login state.
    notifyListeners(); // Notify listeners about state changes.
  }

  // Method to change the current tab.
  void goToTab(index) {
    _selectedTab = index;
    notifyListeners(); // Notify listeners about tab change.
  }

  // Method to navigate to the 'Weekly Menu' tab.
  void goToDishes() {
    _selectedTab = NutriAppTab.weeklyMenu;
    notifyListeners(); // Notify listeners about tab change.
  }

  // Method to handle user logout.
  void logout() async {
    _loggedIn = false; // Reset login status.
    _selectedTab = NutriAppTab.shoppingList; // Reset the selected tab.

    await _appCache.invalidate(); // Invalidate the user cache.
    await initializeApp(); // Reinitialize the app.
    notifyListeners(); // Notify listeners about state changes.
  }
}
