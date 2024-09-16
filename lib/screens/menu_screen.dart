// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profile_screen.dart';
import 'package:flutter_app/screens/articles_screen.dart';
import 'package:flutter_app/screens/users_screen.dart';
import 'package:flutter_app/screens/chatboot_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú Principal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildMenuItem(Icons.person, 'Perfil', context, ProfileScreen()),
            _buildMenuItem(Icons.article, 'Artículos', context, const ArticlesScreen()),
            _buildMenuItem(Icons.people, 'Usuarios', context, UsersScreen()),
            _buildMenuItem(Icons.chat, 'Chatboot', context, const ChatbootScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: const Color.fromARGB(255, 177, 33, 165)),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
