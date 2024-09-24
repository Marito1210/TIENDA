import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

// ignore: use_key_in_widget_constructors
class ProfileScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final profile = await authService.getProfile();
      print('Perfil del usuario: $profile'); // Agregado para verificar el perfil
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: avoid_print
      print('Error al obtener el perfil del usuario: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        await authService.uploadProfileImage(_imageFile!);
        // Actualiza el perfil después de subir la imagen
        await fetchUserProfile(); 
      } catch (e) {
        print('Error al subir la imagen: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
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
                      // Círculo con foto de usuario
                      CircleAvatar(
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) // Muestra la imagen seleccionada
                            : userProfile!['image'] != null
                                ? NetworkImage('http://192.168.1.10:8000${userProfile!['image']}')
                                : const AssetImage('assets/user_placeholder.png'),
                        radius: 80,
                        backgroundColor: Colors.purple[100],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Seleccionar Imagen'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: const Text('Subir Imagen'),
                      ),
                      const SizedBox(height: 10),
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
                                  Expanded(
                                    child: Text(
                                      'Nombre: ${userProfile!['username'] ?? 'Sin nombre'}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.email, color: Colors.purple),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Correo: ${userProfile!['email'] ?? 'Sin correo'}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
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
