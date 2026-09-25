import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/signup.dart'; // Make sure this path matches your file location

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Sign Up Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CustomerSignUpPage(),
    );
  }
}