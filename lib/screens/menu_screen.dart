import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profile_screen.dart';
import 'package:flutter_app/screens/articles_screen.dart';
import 'package:flutter_app/screens/users_screen.dart';
import 'package:flutter_app/screens/chatboot_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0; // Indice del menú seleccionado

  // Lista de widgets para cada opción del menú
  static final List<Widget> _widgetOptions = <Widget>[
    ProfileScreen(),
   ArticlesScreen(),
    UsersScreen(),
    const ChatbootScreen(),
  ];

  // Función que cambia el índice seleccionado cuando se presiona un ítem del menú
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Actualiza el índice con el seleccionado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _widgetOptions.elementAt(_selectedIndex), // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Ícono del perfil
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article), // Ícono de artículos
            label: 'Artículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), // Ícono de usuarios
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // Ícono del chatboot
            label: 'Chatboot',
          ),
        ],
        currentIndex: _selectedIndex, // Índice seleccionado actualmente
        selectedItemColor: const Color.fromARGB(255, 166, 52, 233), // Color del ítem seleccionado
        unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
        onTap: _onItemTapped, // Al tocar un ítem, llama a la función _onItemTapped
      ),
    );
  }
}
