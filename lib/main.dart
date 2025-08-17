import 'package:chat/screens/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          onPrimaryFixed: Colors.lightBlueAccent.shade700,
          seedColor: Colors.white,
          primary: Colors.pink,
          secondary: Colors.blue.shade100,
          tertiary: Colors.purple.shade400,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
