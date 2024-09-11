import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', 
        style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfile == null
              ? Center(child: Text('No se pudieron cargar los datos del perfil'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Círculo con foto de usuario
                       SizedBox(height: 150),
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/user_placeholder.png'), // Cambia a tu imagen de usuario
                        radius: 80,
                        backgroundColor: Colors.purple[100],
                        
                      ),
                      SizedBox(height: 10),
                      // Datos del usuario
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.purple),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Nombre: ${userProfile!['username'] ?? 'Sin nombre'}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.purple),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Correo: ${userProfile!['email'] ?? 'Sin correo'}',
                                      style: TextStyle(fontSize: 18),
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
