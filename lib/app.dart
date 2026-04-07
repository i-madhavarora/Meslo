import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/chat_list_screen.dart';
import 'presentation/screens/splash_screen.dart';

class EchoMeshApp extends StatelessWidget {
  const EchoMeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoMesh Messenger',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/chats': (_) => const ChatListScreen(),
      },
    );
  }
}
