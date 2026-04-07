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
      appBar: AppBar(title: Text("Setup Profile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username (@optional)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createUser,
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}