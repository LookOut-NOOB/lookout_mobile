import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/main.dart';
import 'package:look_out/views/auth/user_form.dart';

import '../app_viewmodel.dart';

class LoginView extends StatelessWidget {
  static const String routeName = "login";
  LoginView({Key? key}) : super(key: key);
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  Widget build(BuildContext context) {
    const providerConfigs = [PhoneProviderConfiguration()];

    return SignInScreen(
      providerConfigs: providerConfigs,
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        }),
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return Container(
          color: Colors.white,
          child: Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: 80,
            ),
          ),
        );
      },
      subtitleBuilder: (context, action) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  appSlogan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // return Scaffold(
    //   body: Column(
    //     children: [
    //       Expanded(
    //         flex: 4,
    //         child: Container(
    //           color: const Color(0xFFF7F8FC),
    //           child: Center(
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 Image.asset(
    //                   "assets/images/logo.png",
    //                   width: 200,
    //                 ),
    //                 const Padding(
    //                   padding: EdgeInsets.symmetric(horizontal: 40),
    //                   child: Text(
    //                     appSlogan,
    //                     textAlign: TextAlign.center,
    //                     style: TextStyle(
    //                       fontSize: 18,
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: Container(
    //           padding: const EdgeInsets.all(20),
    //           decoration: BoxDecoration(
    //               color: Theme.of(context).primaryColor,
    //               borderRadius: const BorderRadius.vertical(
    //                 top: Radius.circular(28),
    //               )),
    //           child: Center(
    //             child: ElevatedButton(
    //                 style: ElevatedButton.styleFrom(
    //                     primary: const Color(0xFFF7F8FC)),
    //                 onPressed: () => _login(context),
    //                 // onPressed: () {
    //                 //   Navigator.of(context).pushReplacement(
    //                 //       MaterialPageRoute(builder: (context) => const App()));
    //                 // },
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(16.0),
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       Text(
    //                         "Continue with phone number",
    //                         style: TextStyle(
    //                           color: Theme.of(context).primaryColor,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 )),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  _login(BuildContext context) async {
    final providers = [
      AuthUiProvider.phone,
    ];

    final result = await FlutterAuthUi.startUi(
      items: providers,
      tosAndPrivacyPolicy: const TosAndPrivacyPolicy(
        tosUrl: "https://sites.google.com/view/lookout-fp/",
        privacyPolicyUrl: "https://sites.google.com/view/lookout-fp/",
      ),
      androidOption: const AndroidOption(
        // showLogo: true, // default false
        overrideTheme: true, // default false
      ),
    ).then((value) {
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login was not successful"),
      ));
    });
  }

  void findUser(BuildContext context, String uid) {
    FirebaseFirestore.instance.collection('users').doc(uid).get().then((value) {
      //pop loading dialog
      Navigator.of(context).pop();
      if (value.exists) {
        Navigator.of(context).pushReplacementNamed("/");
        appViewModel.repository
            .getUserProfile(FirebaseAuth.instance.currentUser?.uid);
      } else {
        Navigator.of(context).pushReplacementNamed(UserForm.routeName);
      }
    }).catchError((error) {
      //pop loading dialog
      Navigator.of(context).pop();
      printDebug("Error:$error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get user data')));
    });
  }
}
