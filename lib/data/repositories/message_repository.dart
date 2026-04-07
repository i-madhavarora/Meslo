import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/hive_service.dart';
import '../models/message.dart';

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _messageStream = StreamController<List<Message>>.broadcast();
  Stream<List<Message>> get messageStream => _messageStream.stream;

  MessageRepository() {
    // 🔥 push existing messages initially
    _emitMessages();
  }

  // 🔥 COMMON EMIT FUNCTION
  void _emitMessages() {
    final messages = getLocalMessages();
    _messageStream.add(messages);
  }

  // 🔥 SEND MESSAGE (LOCAL + FIREBASE + STREAM UPDATE)
  Future<void> sendMessage(Message message) async {
    await HiveService.saveMessage(message);

    // 🔥 update UI instantly
    _emitMessages();

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

  // 🔥 LOCAL FETCH
  List<Message> getLocalMessages() {
    return HiveService.getMessages();
  }

  // 🔥 CLEANUP (optional but good practice)
  void dispose() {
    _messageStream.close();
  }
}