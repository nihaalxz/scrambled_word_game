import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            textStyle: const TextStyle(fontSize: 24),
          ),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => GameScreen())
            );
          },
          child: const Text("Start Game"),
        ),
      ),
    );
  }
}
