
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class AuthService {
 final String baseUrl = 'http://192.168.1.10:8000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Función para registrar usuarios
  Future<void> register(String username, String password, String email) async {
    final url = Uri.parse('$baseUrl/usuarios/create/');
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
    
    // Almacena el access token
    await _storage.write(key: 'access_token', value: data['access']);
    
    // Almacena el refresh token
    await _storage.write(key: 'refresh_token', value: data['refresh']);
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
  // Función para refrescar el token
Future<void> refreshToken() async {
  final url = Uri.parse('$baseUrl/token/refresh/');
  
  // Obtiene el refresh token almacenado (asegúrate de que lo almacenes durante el login)
  final refreshToken = await _storage.read(key: 'refresh_token');
  if (refreshToken == null) {
    throw Exception('No se encontró el refresh token. Debes iniciar sesión nuevamente.');
  }
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'refresh': refreshToken,
    }),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Guarda el nuevo access token
    await _storage.write(key: 'access_token', value: data['access']);
  } else {
    throw Exception('Error al refrescar el token: ${response.body}');
  }
}
//funcion para verificar si nececsita el token
Future<void> refreshIfNeeded() async {
  final token = await getToken();
  if (token == null) {
    await refreshToken();
  }
}

  // Función para obtener usuarios
 Future<List<dynamic>> getUsuarios() async {
  await refreshIfNeeded(); // Verifica y refresca el token si es necesario
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
    await refreshIfNeeded(); // Verifica y refresca el token si es necesario
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

// Actualizar perfil
Future<void> updateProfile(String username, String email, String password, File? image) async {
  await refreshIfNeeded(); // Verifica y refresca el token si es necesario
  final token = await getToken();
  final url = Uri.parse('$baseUrl/usuarios/actualizar/');
  // Crear el request multipart
  var request = http.MultipartRequest('PUT', url)
    ..headers['Authorization'] = 'Bearer $token'
    ..headers['Content-Type'] = 'multipart/form-data'
    ..fields['username'] = username
    ..fields['email'] = email;
  
  // Agregar la contraseña si se proporciona
  if (password.isNotEmpty) {
    request.fields['password'] = password;
  }
  // Agregar la imagen si se proporciona
  if (image != null) {
    var mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');
    var imageFile = await http.MultipartFile.fromPath(
      'image', 
      image.path,
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1])
    );
    request.files.add(imageFile);
  }
  // Enviar el request
  var response = await request.send();
  // Verificar la respuesta
  if (response.statusCode != 200) {
    final respStr = await response.stream.bytesToString();
    throw Exception('Error al actualizar el perfil: $respStr');
  }
}
//eliminar perfil autenticado
 Future<void> deleteProfile() async {
  await refreshIfNeeded(); // Verifica y refresca el token si es necesario
  final token = await getToken();
  final url = Uri.parse('$baseUrl/usuarios/eliminar/');

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Este encabezado puede ser opcional
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Error al eliminar el perfil: ${response.body}');
  }
}


  // Función para obtener categorías
  Future<List<dynamic>> getCategorias() async {
    await refreshIfNeeded(); // Verifica y refresca el token si es necesario
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
// Método para agregar una categoría
  Future<void> addCategoria(String name, String description) async {
    await refreshIfNeeded(); // Verifica y refresca el token si es necesario
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/create/');
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

//ARTICULOS

Future<void> addArticulo(
  String name,
  String description,
  double price,
  int stock,
  int authorId,
  int categoryId,
  File imageFile,  // Imagen como archivo
  int warrantyPeriod
) async {
  await refreshIfNeeded();  // Verifica y refresca el token si es necesario
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/create/');

  // Crea una solicitud multipart para enviar datos y archivos
  var request = http.MultipartRequest('POST', url);
  // Agrega los encabezados
  request.headers['Authorization'] = 'Bearer $token';
  // Agrega los campos normales
  request.fields['name'] = name;
  request.fields['description'] = description;
  request.fields['price'] = price.toString();
  request.fields['stock'] = stock.toString();
  request.fields['author'] = authorId.toString();
  request.fields['category'] = categoryId.toString();
  request.fields['warranty_period'] = warrantyPeriod.toString();
  // Agrega el archivo de imagen (con su tipo MIME)
  var stream = http.ByteStream(imageFile.openRead());
  var length = await imageFile.length();
  var multipartFile = http.MultipartFile(
    'image',  // Nombre del campo en la API
    stream,
    length,
    filename: imageFile.path.split('/').last,  // Obtiene el nombre del archivo
    contentType: MediaType('image', 'jpeg'),  // Ajusta según el tipo de imagen
  );
  request.files.add(multipartFile);
  // Envía la solicitud
  var response = await request.send();
  // Verifica el código de respuesta
  if (response.statusCode == 201) {
    // Artículo agregado exitosamente
    print("Artículo creado exitosamente");
  } else {
    // Error al crear el artículo
    final respStr = await response.stream.bytesToString();
    throw Exception('Error al agregar el artículo: $respStr');
  }
}

// Función para obtener artículos 
Future<List<dynamic>> getArticulos() async {
    await refreshIfNeeded(); // Verifica y refresca el token si es necesario
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
    // Verifica qué datos estás recibiendo
    print('Respuesta de la API: $jsonResponse'); 
    // Asegurarte de que la respuesta sea una lista de artículos
    List<dynamic> articulos;
    if (jsonResponse is Map && jsonResponse.containsKey('data')) {
      articulos = jsonResponse['data'];
    } else if (jsonResponse is List) {
      articulos = jsonResponse;
    } else {
      throw Exception('Estructura de respuesta inesperada para artículos');
    }
    // Validar cada artículo para asegurar que los campos sean correctos, incluyendo description
    return articulos.map((articulo) {
      return {
        'id': articulo['id'] ?? 0,  // Asegúrate de incluir el 'id'
        'name': articulo['name'] ?? 'Nombre no disponible',
        'description': articulo['description'] ?? 'Descripción no disponible',
        'category_name': articulo['category_name'] ?? 'Sin categoría',
        'imagen': articulo['imagen'] ?? '', // Si tienes un campo de imagen también
      };
    }).toList();
  } else {
    throw Exception('Error al obtener los artículos: ${response.body}');
  }
}
 // Función para obtener los detalles completos de un artículo
Future<Map<String, dynamic>> getArticuloDetailByID(int id) async {
 await refreshIfNeeded(); // Verifica y refresca el token si es necesario
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/$id/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    print('Detalles del artículo: $jsonResponse');
    
    return {
      'id': jsonResponse['id'] ?? 0,
      'name': jsonResponse['name'] ?? 'Nombre no disponible',
      'description': jsonResponse['description'] ?? 'Descripción no disponible',
      'category_name': jsonResponse['category_name'] ?? 'Sin categoría',
      'image': jsonResponse['image'] ?? '',
      'author_name': jsonResponse['author_name'] ?? 'Autor no disponible',
      'price': jsonResponse['price'] ?? 0.0,
      'stock': jsonResponse['stock'] ?? 0,
      'created_at': jsonResponse['created_at'] ?? 'Fecha no disponible',
      'warranty_expiration': jsonResponse['warranty_expiration'] ?? 'Sin garantía',
    };
  } else {
    throw Exception('Error al obtener detalles del artículo: ${response.body}');
  }
}


  // Método para editar un artículo
  Future<void> editArticulo(int id, String name, String description, double price, int stock, int category, double warrantyperiod, File? selectedImage) async {
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
        'warranty_period': warrantyperiod,
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




//articulos fav
Future<void> toggleFavorito(int articuloId) async {
  final token = await getToken();
  final url = '$baseUrl/articulos/favoritos/';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'articulo_id': articuloId}),
    );

    if (response.statusCode != 200) {
      // Muestra el cuerpo de la respuesta para depuración en caso de error
      final error = jsonDecode(response.body);
      throw Exception('Error al agregar/eliminar artículo de favoritos: ${error['detail']}');
    }
  } catch (e) {
    print('Error: $e');
    rethrow; // Relanza el error para que pueda ser capturado en otras partes si es necesario
  }
}



}

