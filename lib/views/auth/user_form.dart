import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:look_out/app.dart';
import 'package:look_out/main.dart';

class UserForm extends StatefulWidget {
  const UserForm({Key? key}) : super(key: key);

  static const String routeName = "user_form";

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final double formSpace = 12;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    FirebaseAuth.instance.signOut();
    super.dispose();
  }

  @override
  void initState() {
    phone.text = FirebaseAuth.instance.currentUser!.phoneNumber!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your information"),
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Visibility(
                  visible: isLoading, child: const LinearProgressIndicator()),
              const Padding(
                padding: EdgeInsets.all(8),
              ),
              TextFormField(
                controller: firstName,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                decoration: _inputDeco(label: "First Name"),
              ),
              _formSpace(),
              TextFormField(
                  controller: lastName,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your Last name';
                    }
                    return null;
                  },
                  decoration: _inputDeco(label: "Last Name")),
              _formSpace(),
              TextFormField(
                  controller: email,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: _inputDeco(label: "Email")),
              _formSpace(),
              TextFormField(
                  controller: phone,
                  enabled: false,
                  decoration: _inputDeco(label: "Phone Number")),
              const Padding(
                padding: EdgeInsets.all(16),
              ),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    primary: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveUser();
                    }
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  void _saveUser() {
    setState(() {
      isLoading = true;
    });
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(user!.uid).set({
      'firstName': firstName.text,
      'lastName': lastName.text,
      'email': email.text,
      'phone': phone.text,
      'id': user!.uid,
      'createdAt': DateTime.now().toString()
    }).then((value) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacementNamed(context, App.routeName);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save data')));
      printDebug("Failed to add user: $error");
    });
  }

  InputDecoration _inputDeco({label}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      // hintText: 'Enter your first name'
    );
  }

  Padding _formSpace() {
    return Padding(
      padding: EdgeInsets.all(formSpace),
    );
  }
}
