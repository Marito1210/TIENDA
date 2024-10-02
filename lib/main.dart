// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/register_screen.dart';
import 'package:flutter_app/screens/menu_screen.dart';
import 'package:flutter_app/screens/profile_screen.dart';
import 'package:flutter_app/screens/articles_screen.dart';
import 'package:flutter_app/screens/users_screen.dart';
import 'package:flutter_app/screens/chatboot_screen.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/menu': (context) => const MenuScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/articles': (context) =>  const ArticlesScreen(),
        '/users': (context) => UsersScreen(),
        '/chatboot': (context) => const ChatbootScreen(),
      },
    );
  }
}
