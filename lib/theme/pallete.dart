import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//provider to control the theme
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class Pallete {
  //color schemes:
  //k is for global variables
  var kColorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 96, 59, 181),
  );

//to switch to Dark mode:
  var kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark, // to adjust the theme to dark mode
    seedColor: const Color.fromARGB(255, 5, 99, 125),
  );

  // Colors
  static const blackColor = Color.fromRGBO(20, 19, 19, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: blackColor,
      cardColor: greyColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: drawerColor,
        iconTheme: IconThemeData(
          color: whiteColor,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: drawerColor,
      ),
      primaryColor: redColor,
      backgroundColor:
          drawerColor, // will be used as alternative background color
      colorScheme: ThemeData.dark()
          .colorScheme
          .copyWith(background: Pallete.drawerColor));

  static var lightModeAppTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: whiteColor,
      cardColor: greyColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: blackColor,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: whiteColor,
      ),
      primaryColor: redColor,
      backgroundColor: whiteColor,
      colorScheme: ThemeData.light()
          .colorScheme
          .copyWith(background: Pallete.whiteColor));
}

//to toggle between dark/light mode
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;
  //initial theme is dark mode
  ThemeNotifier({ThemeMode mode = ThemeMode.dark})
      : _mode = mode,
        super(Pallete.darkModeAppTheme) {
    //whenever the constuctor runs, call getTheme
    getTheme();
  }

  //getter to get themeMode now:
  ThemeMode get mode => _mode;

  //to get the theme as soon as the app starts
  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Reads a value from persistent storage, with the key 'theme'
    final theme = prefs.getString('theme');
    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  //to use in the check button in the side drawer
  //is async because we're use shared preferences package, which stores data in the device memory
  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //if it's dark mode, switch to light mode
    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
      // print(_mode);
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
      // print(_mode);
    }
  }
}
