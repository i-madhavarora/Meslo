import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message.dart';
import '../../data/repositories/message_repository.dart';
import '../../services/user_service.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> {
  final repo = MessageRepository();
  final controller = TextEditingController();
  final uuid = const Uuid();

  Future<void> sendMessage() async {
    final user = await UserService().getUser();

    if (user == null) return; // or handle properly

    final msg = Message(
      id: uuid.v4(),
      text: controller.text,
      senderId: user.userId,   // ❌ not "me"
      receiverId: "user",       // (temporary for now)
      timestamp: DateTime.now(),
      senderName: user.name,
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
              IconButton(onPressed: sendMessage, icon: const Icon(Icons.send))
            ],
          )
        ],
      ),
    );
  }
}