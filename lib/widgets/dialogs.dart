import 'package:flutter/material.dart';

loadingDialog(BuildContext context, {String? message}) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(
            margin: const EdgeInsets.only(left: 12),
            child: Text(message ?? "Loading")),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

infoDialog(BuildContext context, {String? message}) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const Icon(Icons.info_outline),
        Container(
            margin: const EdgeInsets.only(left: 7),
            child: Text(message ?? "Done")),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text("Okay"),
      )
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showToast(BuildContext context, {required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}

popDialog(BuildContext context) {
  Navigator.of(context).pop();
}
