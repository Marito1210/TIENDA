import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Para seleccionar la imagen
import 'package:flutter_app/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  File? _image; // Para almacenar la imagen seleccionada

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final profile = await authService.getProfile();
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al obtener el perfil del usuario: $e');
    }
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      return 'http://192.168.1.10:8000$imagePath';
    }
  }

  Future<void> _updateProfile(String username, String email, String password) async {
    try {
      await authService.updateProfile(username, email, password, _image);
      fetchUserProfile(); // Refrescar el perfil después de actualizarlo
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Cerrar el diálogo
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Perfil actualizado con éxito'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      // ignore: avoid_print
      print('Error al actualizar el perfil: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al actualizar el perfil: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteProfile() async {
    try {
      await authService.deleteProfile(); // Llama a la función de eliminación del perfil
      Navigator.of(context).pop(); // Cerrar la pantalla de perfil después de eliminar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Perfil eliminado con éxito'),
        backgroundColor: Colors.green,
      ));
      // Puedes redirigir a la pantalla de inicio de sesión o cualquier otra pantalla aquí
    } catch (e) {
      print('Error al eliminar el perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar el perfil: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showUpdateProfileDialog() async {
    final TextEditingController usernameController = TextEditingController(text: userProfile?['username']);
    final TextEditingController emailController = TextEditingController(text: userProfile?['email']);
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Actualizar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña (dejar en blanco si no desea cambiarla)'),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                _image == null
                    ? TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Seleccionar imagen'),
                      )
                    : Image.file(_image!, height: 100),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateProfile(
                  usernameController.text,
                  emailController.text,
                  passwordController.text.isEmpty ? '' : passwordController.text,
                );
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, ), // Icono de tres puntos
             
            onSelected: (String result) {
              if (result == 'update') {
                _showUpdateProfileDialog(); // Muestra el diálogo de actualización de perfil
              } else if (result == 'delete') {
                _deleteProfile(); // Llama a la función para eliminar el perfil
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update',
                child: Text('Actualizar perfil'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Eliminar perfil'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
              ? const Center(child: Text('No se pudieron cargar los datos del perfil'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: userProfile!['image'] != null
                            ? Colors.transparent
                            : Colors.purple[100],
                        backgroundImage: userProfile!['image'] != null
                            ? NetworkImage(_buildImageUrl(userProfile!['image']))
                            : null,
                        child: userProfile!['image'] == null
                            ? const Icon(Icons.person, size: 80, color: Colors.purple)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.purple),
                                  const SizedBox(width: 10),
                                  Text(
                                    userProfile!['username'] ?? 'Sin nombre',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.email, color: Colors.purple),
                                  const SizedBox(width: 10),
                                  Text(
                                    userProfile!['email'] ?? 'Sin email',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
