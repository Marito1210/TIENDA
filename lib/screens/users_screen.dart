import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

// ignore: use_key_in_widget_constructors
class UsersScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AuthService authService = AuthService();
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final data = await authService.getUsuarios();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: avoid_print
      print('Error al obtener los usuarios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Registrados',
        style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple, // Color morado para la barra de la aplicación
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No hay usuarios disponibles'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        elevation: 4, // Elevación para darle un efecto de sombra
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: CircleAvatar(
                            backgroundImage: const AssetImage('assets/user_placeholder.png'), // Imagen de usuario predeterminada
                            radius: 30,
                            backgroundColor: Colors.purple[100],
                          ),
                          title: Text(
                            user['username'] ?? 'Sin nombre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[800], // Texto en morado oscuro
                            ),
                          ),
                          subtitle: Text(
                            user['email'] ?? 'Sin email',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple), // Icono a la derecha
                          onTap: () {
                            // Aquí podrías mostrar más detalles del usuario si lo deseas
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
