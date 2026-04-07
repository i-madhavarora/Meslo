import 'package:hive/hive.dart';
import '../data/models/message.dart';

class HiveService {
  static late Box<Message> messageBox;
  static Future<void> init() async {
    Hive.registerAdapter(MessageAdapter());
    messageBox = await Hive.openBox<Message>('messages');
  }

  static Future<void> saveMessage(Message message) async {
    await messageBox.put(message.id, message);
  }

  static List<Message> getMessages() {
    return messageBox.values.toList();
  }
}
