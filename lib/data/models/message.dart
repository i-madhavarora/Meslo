import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String senderId;

  @HiveField(3)
  String receiverId;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String senderName;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.senderName,
  });
}
