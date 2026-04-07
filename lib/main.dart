import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:meslo/presentation/screens/chat_screen.dart';
import 'package:meslo/presentation/screens/name_screen.dart';
import 'package:meslo/services/background_service.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final user = await UserService().getUser();

  runApp(MyApp(user: user));
}

void startBackgroundService() {
  FlutterForegroundTask.startService(
    notificationTitle: 'Meslo Running',
    notificationText: 'Maintaining connection...',
    callback: startCallback,
  );
}

void startCallback() {
  FlutterForegroundTask.setTaskHandler(BleTaskHandler());
}

class MyApp extends StatelessWidget {
  final UserModel? user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? NameScreen() : ChatScreen(),
    );
  }
}
