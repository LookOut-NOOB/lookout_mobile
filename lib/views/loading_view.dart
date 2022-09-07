import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingView extends StatelessWidget {
  static const String routeName = "loading";
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  color: const Color(0xffED1F44),
                  height: 100,
                  width: 150,
                ),
              ),
            ),
            Lottie.asset(
              "assets/animations/loading.json",
              fit: BoxFit.contain,
              height: 100,
              width: 100,
            ),
          ],
        ),
      ),
    );
  }
}
