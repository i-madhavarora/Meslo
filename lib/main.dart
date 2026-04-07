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

Future<void> initForegroundTask() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'echomesh_channel',
      channelName: 'EchoMesh Service',
      channelDescription: 'Keeps BLE running',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),

    // ✅ REQUIRED (even if unused)
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),

    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
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
