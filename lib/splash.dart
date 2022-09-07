import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/app.dart';
import 'package:look_out/main.dart';
import 'package:look_out/views/auth/login.dart';
import 'package:look_out/views/auth/user_form.dart';

import 'views/app_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final appViewModel = GetIt.instance<AppViewModel>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoggedIn(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Center(
              child: Text("Loading"),
            )
          ],
        ),
      ),
    );
  }

  _checkLoggedIn(context) async {
    printDebug(":::::Checking loged in");
    try {
      var user = FirebaseAuth.instance.currentUser;
      printDebug(" ::::: is_$user");
      if (user != null) {
        findUserFromDb(context, user.uid);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginView.routeName);
      }
    } catch (error) {
      print("eeeeeeeeeeeeeeee");
      printDebug("Caught error: $error");
      Navigator.of(context).pushReplacementNamed(LoginView.routeName);
    }
  }

  void findUserFromDb(BuildContext context, String uid) {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((value) {
        if (value.exists) {
          appViewModel.repository
              .getUserProfile(FirebaseAuth.instance.currentUser?.uid);
          Navigator.of(context).pushReplacementNamed(App.routeName);
        } else {
          Navigator.of(context).pushReplacementNamed(UserForm.routeName);
        }
      }).catchError((error) {
        printDebug("Error:$error");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get user data')));
      });
    } catch (e) {
      printDebug("Error finding user: $e");
    }
  }
}
