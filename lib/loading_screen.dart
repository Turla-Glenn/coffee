import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:coffee/menu_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late bool _isConnected = true; // Initialize to true by default

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Reload the screen when connection is restored
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });

      // Delay for demonstration purposes
      await Future.delayed(Duration(seconds: 4));

      if (_isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isConnected == false
            ? AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/load.gif', // Path to your loading GIF
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
