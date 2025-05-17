import 'package:flutter/material.dart';
import '/screens/home.dart'; // Make sure this file contains your HomePage widget
import 'screens/login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Login(),
    );
  }
}
