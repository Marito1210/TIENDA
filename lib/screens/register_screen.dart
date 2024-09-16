import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';

// ignore: use_key_in_widget_constructors
class RegisterScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    try {
      await _authService.register(
        _usernameController.text,
        _passwordController.text,
        _emailController.text,
      );
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Usuario registrado exitosamente'),
      ));
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error en el registro: ${e.toString()}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Parte superior morada con logo
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      child: Text(
                        'TIENDA',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 90),

            // Campos de nombre de usuario, email y contraseña
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.purple),
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.purple[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.purple),
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.purple[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.purple),
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.purple[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Botón de registro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('REGISTRAR',
                style: TextStyle(color: Colors.white), // Aquí cambiamos el color del texto a blanco
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón de iniciar sesión
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text(
                '¿Ya tienes cuenta? Inicia sesión aquí',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
