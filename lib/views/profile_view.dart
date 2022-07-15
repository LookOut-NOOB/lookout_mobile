import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/profile.dart';
import 'app_viewmodel.dart';

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
                        TextField(
                          controller: firstName,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                        ),
                        TextField(
                          controller: lastName,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                        ),
                        TextField(
                          controller: phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                          ),
                        ),
                        TextField(
                          controller: email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
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
