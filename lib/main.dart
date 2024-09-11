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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/menu': (context) => MenuScreen(),
        '/profile': (context) => ProfileScreen(),
        '/articles': (context) => ArticlesScreen(),
        '/users': (context) => UsersScreen(),
        '/chatboot': (context) => ChatbootScreen(),
      },
    );
  }
}
