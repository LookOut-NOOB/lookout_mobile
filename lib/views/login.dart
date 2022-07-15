import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  static const String routeName = "login";
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Login"),
      ),
    );
  }
}
