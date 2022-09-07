import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/models/profile.dart';
import 'package:look_out/views/app_viewmodel.dart';
import 'package:look_out/widgets/dialogs.dart';

import '../main.dart';

class ProfileView extends StatefulWidget {
  static const String routeName = "profile";

  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final firstName = TextEditingController();

  final lastName = TextEditingController();

  final email = TextEditingController();

  final address = TextEditingController();

  final phone = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  void initState() {
    phone.text = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Profile? thisProfile;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data != null && snapshot.data!.data() != null) {
              var profile = Profile.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              thisProfile = profile;
              firstName.text = profile.firstName!;
              lastName.text = profile.lastName!;
              email.text = profile.email!;
            }
            return SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          controller: firstName,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter first name";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: lastName,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter first name";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          enabled: false,
                          controller: phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter first name";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter first name";
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              primary: Theme.of(context).primaryColor,
                            ),
                            onPressed: thisProfile == null
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      loadingDialog(context,
                                          message:
                                              "Saving profile information");
                                      CollectionReference users =
                                          FirebaseFirestore.instance
                                              .collection('users');
                                      users.doc(thisProfile!.uid).update({
                                        'firstName': firstName.text,
                                        'lastName': lastName.text,
                                        'email': email.text,
                                      }).then((value) {
                                        //pop loading dialog
                                        Navigator.of(context).pop();
                                        //pop profile page
                                        Navigator.of(context).pop();
                                      }).catchError((error) {
                                        //pop loading dialog
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Failed to edit profile')));
                                        printDebug(
                                            "Failed to edit profile: $error");
                                      });
                                    }
                                  },
                            child: const Text(
                              "Edit profile",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
