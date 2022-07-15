import 'package:flutter/material.dart';
class ErrorView extends StatelessWidget {
  final String? error; 
  const ErrorView({ Key? key, this.error }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Text(error ?? "Error"),
      ),
      
    );
  }
}