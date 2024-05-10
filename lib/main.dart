// main.dart
import 'package:flutter/material.dart';
import 'package:coffee/drawer_screen.dart';
import 'package:coffee/menu_screen.dart';

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
        primaryColor: Colors.brown[100],
        appBarTheme: AppBarTheme(
          color: Colors.brown[400],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ),
          ),
        ),
      ),
      home: MenuScreen(),
    );
  }
}
