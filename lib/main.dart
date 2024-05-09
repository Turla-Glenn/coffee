import 'package:flutter/material.dart';
import 'package:coffee/drawer_and_update_delete_screen.dart'; // Import the DrawerScreen
import 'package:coffee/menu_screen.dart'; // Import the MenuScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Shop',
      theme: ThemeData(
        primaryColor: Colors.brown[100], // Beige
        appBarTheme: AppBarTheme(
          color: Colors.brown[400], // Brown
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white, // Dark Brown
            ),
          ),
        ),
      ),
      home: MenuScreen(),
    );
  }
}