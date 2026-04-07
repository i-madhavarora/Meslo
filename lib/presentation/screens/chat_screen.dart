import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message.dart';
import '../../data/repositories/message_repository.dart';
import '../../models/user_model.dart';
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

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    currentUser = await UserService().getUser();
    setState(() {});
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final messages = repo.getLocalMessages();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("EchoMesh"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == currentUser?.userId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(colors: [Colors.blue, Colors.blueAccent])
                          : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700]),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: isMe ? Radius.circular(18) : Radius.circular(0),
                        bottomRight: isMe ? Radius.circular(0) : Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.senderName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message.text,
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(width: 4),

                            if (isMe)
                              Icon(
                                Icons.done_all,
                                size: 14,
                                color: isMe ? Colors.lightBlueAccent : Colors.white70,
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // INPUT BAR
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send, color: Colors.blue),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}