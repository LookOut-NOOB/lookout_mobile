import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app.dart';
import '../widgets/dialogs.dart';
import 'app_viewmodel.dart';
import 'login.dart';
import 'profile_view.dart';

class SettingsView extends StatelessWidget {
  static const String routeName = "settings";
  const SettingsView({Key? key}) : super(key: key);

  static Future<void> logout(context) async {
    final appViewModel = GetIt.instance<AppViewModel>();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Log out'),
          content: const Text('Would you like to log out from $appName?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onPressed: () {
                loadingDialog(context, message: "Logging out");
                appViewModel.repository.logOut().then((value) {
                  popDialog(context);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginView.routeName, (route) => false);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Profile"),
            subtitle: const Text("View and edit your profile"),
            onTap: () {
              Navigator.of(context).pushNamed(ProfileView.routeName);
            },
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          ),
          ListTile(
            title: const Text("Log out"),
            subtitle: const Text("Logout from your $appName account"),
            onTap: () {
              SettingsView.logout(context);
            },
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          ),
        ],
      ),
    );
  }
}
