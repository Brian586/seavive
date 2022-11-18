import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seavive/config.dart';
import 'package:seavive/pages/authPage.dart';
import 'package:seavive/pages/home.dart';

// Import the generated file
import 'firebase_options.dart';
import 'models/account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeaVive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  displaySplash() async {
    Timer(const Duration(seconds: 3), () async {
      auth.authStateChanges().listen((User? user) async {
        if (user == null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AuthPage()));
        } else {
          final user = FirebaseAuth.instance.currentUser;

          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .get()
              .then((value) {
            Account account = Account.fromDocument(value);

            context.read<SeaVive>().switchUser(account);
          });

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Text(
          "SeaVive",
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
