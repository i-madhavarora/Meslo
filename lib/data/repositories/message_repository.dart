import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/hive_service.dart';
import '../models/message.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message) async {
    await HiveService.saveMessage(message);

    try {
      await _firestore.collection('messages').doc(message.id).set({
        "text": message.text,
        "senderId": message.senderId,
        "receiverId": message.receiverId,
        "timestamp": message.timestamp.toIso8601String(),
      });
    } catch (e) {
      debugPrint("Offline - saved locally");
    }
  }

  List<Message> getLocalMessages() {
    return HiveService.getMessages();
  }
}