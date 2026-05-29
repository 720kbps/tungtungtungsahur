import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          "Welcome!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}