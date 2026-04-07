import 'package:flutter/material.dart';
import 'package:meslo/main.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/message.dart';
import '../../data/repositories/message_repository.dart';
import '../../models/user_model.dart';
import '../../services/ble_manager.dart';
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
  final ble = BleManager().service;

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    loadUser();

    startBackgroundService();

    // for logout :- FlutterForegroundTask.stopService();

    // ✅ Pair request UI
    ble.onPairRequest = (sender) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Pair Request"),
          content: Text("Connect with $sender ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Reject"),
            ),
            TextButton(
              onPressed: () {
                ble.acceptPair(sender);
                Navigator.pop(context);
              },
              child: const Text("Accept"),
            ),
          ],
        ),
      );
    };

    // ✅ Auto reconnect loop
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      await ble.autoReconnect();
      return mounted;
    });
  }

  Future<void> sendMessage() async {
    final user = await UserService().getUser();
    if (user == null) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    final msg = Message(
      id: uuid.v4(),
      text: text,
      senderId: user.userId,
      receiverId: ble.remoteDeviceId ?? "unknown",
      timestamp: DateTime.now(),
      senderName: user.name,
    );

    // ✅ local + stream update
    await repo.sendMessage(msg);

    // ✅ BLE send (encrypted internally)
    await ble.sendChat(text);

    controller.clear();
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

  Widget messageBubble(Message message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        )
            : LinearGradient(
          colors: [Colors.grey.shade800, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft:
          isMe ? const Radius.circular(18) : const Radius.circular(0),
          bottomRight:
          isMe ? const Radius.circular(0) : const Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.senderName,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatTime(message.timestamp),
                style:
                const TextStyle(fontSize: 10, color: Colors.white70),
              ),
              const SizedBox(width: 4),
              if (isMe)
                const Icon(
                  Icons.done_all,
                  size: 14,
                  color: Colors.lightBlueAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "EchoMesh",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              ble.isConnected
                  ? "Connected: ${ble.remoteDeviceId ?? 'Device'}"
                  : "Disconnected",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0f2027),
              Color(0xFF203a43),
              Color(0xFF2c5364)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: repo.messageStream,
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe =
                          message.senderId == currentUser?.userId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: messageBubble(message, isMe),
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              margin: const EdgeInsets.all(10),
              padding:
              const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4facfe),
                            Color(0xFF00f2fe)
                          ],
                        ),
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}