import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
 final String baseUrl = 'http://192.168.1.10:8000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
      throw Exception('Error al registrar el usuario: ${response.body}');
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
      throw Exception('Error al iniciar sesión: ${response.body}');
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

      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return jsonResponse['data'];
      } else if (jsonResponse is List) {
        return jsonResponse;
      } else {
        throw Exception('Estructura de respuesta inesperada para artículos');
      }
    } else {
      throw Exception('Error al obtener los artículos: ${response.body}');
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
      throw Exception('Error al obtener los usuarios: ${response.body}');
    }
  }

  // Función para obtener el perfil del usuario autenticado
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/usuarios/perfil/'); 

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
      throw Exception('Error al obtener los detalles del perfil: ${response.body}');
    }
  }

  // Función para obtener categorías
  Future<List<dynamic>> getCategorias() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        return jsonResponse['data'];
      } else if (jsonResponse is List) {
        return jsonResponse;
      } else {
        throw Exception('Estructura de respuesta inesperada para categorías');
      }
    } else {
      throw Exception('Error al obtener las categorías: ${response.body}');
    }
  }

  // Método para agregar un artículo
  Future<void> addArticulo(String name, String description, double price, int stock, int category) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/articulos/');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
      }),
    );

    if (response.statusCode == 201) {
      // Artículo agregado exitosamente
    } else {
      throw Exception('Error al agregar el artículo: ${response.body}');
    }
  }

  // Método para agregar una categoría
  Future<void> addCategoria(String name, String description) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      // Categoría agregada exitosamente
    } else {
      throw Exception('Error al agregar la categoría: ${response.body}');
    }
  }

  // Método para editar un artículo
  Future<void> editArticulo(int id, String name, String description, double price, int stock, int category) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/articulos/$id/');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      // Edición exitosa
    } else {
      throw Exception('Error al editar el artículo: ${response.body}');
    }
  }

  // Método para eliminar un artículo
  Future<void> deleteArticulo(int id) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/articulos/$id/');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el artículo: ${response.body}');
    }
  }

  // Método para editar una categoría
  Future<void> editCategoria(int id, String name, String description) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/$id/');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      // Edición exitosa
    } else {
      throw Exception('Error al editar la categoría: ${response.body}');
    }
  }

  // Método para eliminar una categoría
  Future<void> deleteCategoria(int id) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/$id/');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la categoría: ${response.body}');
    }
  }
}
