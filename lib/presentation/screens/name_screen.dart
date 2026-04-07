import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import 'chat_screen.dart';

class NameScreen extends StatefulWidget {
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  void createUser() async {
    if (nameController.text.isEmpty) return;

    final user = UserModel(
      userId: DateTime.now().millisecondsSinceEpoch.toString() +
          Random().nextInt(9999).toString(),
      name: nameController.text,
      username: usernameController.text.isEmpty
          ? nameController.text
          : usernameController.text,
    );

    await UserService().saveUser(user);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome to EchoMesh",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Your Name",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "@username (optional)",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: createUser,
                child: Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}