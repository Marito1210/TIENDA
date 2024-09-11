import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Función para registrar usuarios
  Future<void> register(String username, String password, String email) async {
    final url = Uri.parse('$baseUrl/usuarios/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      // Registro exitoso
    } else {
      throw Exception('Error al registrar el usuario');
    }
  }

  // Función para iniciar sesión
  Future<void> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access']);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  // Función para obtener el token
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Función para cerrar sesión
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  // Función para obtener artículos
  Future<List<dynamic>> getArticulos() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/articulos/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Respuesta JSON: $jsonResponse');

      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return jsonResponse['data'];
      } else if (jsonResponse is List) {
        return jsonResponse;
      } else {
        throw Exception('Estructura de respuesta inesperada');
      }
    } else {
      throw Exception('Error al obtener los artículos');
    }
  }

  // Función para obtener usuarios
  Future<List<dynamic>> getUsuarios() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/usuarios/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los usuarios');
    }
  }
//funcion para obtener usuartios autenticados
Future<Map<String, dynamic>> getProfile() async {
  final token = await getToken();
  final url = Uri.parse('$baseUrl/usuarios/perfil/');  // Asegúrate de que esta ruta esté disponible en tu API

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al obtener los detalles del perfil');
  }
}


  // Nueva función para obtener categorías
  Future<List<dynamic>> getCategorias() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/');  // Endpoint para obtener categorías

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Respuesta JSON de categorías: $jsonResponse');

      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return jsonResponse['data'];
      } else if (jsonResponse is List) {
        return jsonResponse;
      } else {
        throw Exception('Estructura de respuesta inesperada para categorías');
      }
    } else {
      throw Exception('Error al obtener las categorías');
    }
  }
}
