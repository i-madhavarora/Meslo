import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message.dart';
import '../../data/repositories/message_repository.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> {
  final repo = MessageRepository();
  final controller = TextEditingController();
  final uuid = const Uuid();

  void send() {
    final msg = Message(
      id: uuid.v4(),
      text: controller.text,
      senderId: "me",
      receiverId: "user",
      timestamp: DateTime.now(),
    );

    repo.sendMessage(msg);
    controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final messages = repo.getLocalMessages();

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((m) {
                return ListTile(title: Text(m.text));
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              IconButton(onPressed: send, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}