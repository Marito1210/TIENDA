
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
// Función para obtener artículos del usuario logueado
  Future<List<dynamic>> fetchMisArticulos(int userId) async {
    await refreshIfNeeded(); // Verifica y refresca el token si es necesario
    final token = await getToken();
    final url = Uri.parse('$baseUrl/articulos/usuario/');

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

    // Asegúrate de que la respuesta sea una lista de artículos
    List<dynamic> articulos;
    if (jsonResponse is Map && jsonResponse.containsKey('data')) {
      articulos = jsonResponse['data']; // Asumiendo que aquí obtienes la lista
    } else if (jsonResponse is List) {
      articulos = jsonResponse; // Si es una lista directamente
    } else {
      throw Exception('Estructura de respuesta inesperada para artículos');
    }
    // Mapea cada artículo y asegura que los campos sean correctos
    return articulos.map((articulo) {
      return {
        'id': articulo['id'] ?? 0,  // Asegúrate de incluir el 'id'
        'name': articulo['name'] ?? 'Nombre no disponible',
        'description': articulo['description'] ?? 'Descripción no disponible',
        'category_name': articulo['category_name'] ?? 'Sin categoría',
        'imagen': articulo['imagen'] ?? '', // Si tienes un campo de imagen también
        'is_favorito': articulo['is_favorito'] ?? false, // Usa false como valor por defecto
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

  var request = http.MultipartRequest('PATCH', url)
    ..headers['Authorization'] = 'Bearer $token';

  // Agregar los campos del formulario
  request.fields['name'] = name;
  request.fields['description'] = description;
  request.fields['price'] = price.toString();
  request.fields['stock'] = stock.toString();
  request.fields['category'] = category.toString();
  request.fields['warranty_period'] = warrantyperiod.toString();

  // Si se seleccionó una nueva imagen, agregarla al request
  if (selectedImage != null) {
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      selectedImage.path,
    ));
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    // Edición exitosa
  } else {
    throw Exception('Error al editar el artículo: ${await response.stream.bytesToString()}');
  }
}

 // Método para eliminar un artículo
Future<void> deleteArticulo(int id) async {
  await refreshIfNeeded(); 
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/delete/$id/'); // Agregar el ID del artículo en la URL

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
//ARTICULOS FAV
//Obtener articulos favoritos

//CATEGORIAS
  // Método para editar una categoría
  Future<void> editCategoria(int id, String name, String description) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/update/$id/');

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
    await refreshIfNeeded(); 
    final token = await getToken();
    final url = Uri.parse('$baseUrl/categorias/delete/$id/');

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
 // Función para agregar un artículo a favoritos
  Future<void> agregarAFavoritos(String articleId) async {
    await refreshIfNeeded(); // Verifica y refresca el token si es necesario
    final token = await getToken();
    final url = Uri.parse('$baseUrl/favoritos/add/'); // Ruta para agregar a favoritos

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'articulo_id': articleId, // Asegúrate de que este campo coincide con lo que espera tu API
      }),
    );
    // Imprime la respuesta para depuración
    print('Respuesta del servidor al agregar a favoritos: ${response.body}');
    if (response.statusCode == 201) {
      // Código 201 significa que el recurso se creó exitosamente
      print('Artículo agregado a favoritos con éxito.');
    } else {
      // Maneja el error si la respuesta no es exitosa
      throw Exception('Error al agregar a favoritos: ${response.body}');
    }
  }

// Función para eliminar un artículo de favoritos
Future<void> eliminarDeFavoritos(String articleId) async {
  await refreshIfNeeded(); // Verifica y refresca el token si es necesario
  final token = await getToken(); // Obtén el token actualizado
  final url = Uri.parse('$baseUrl/favoritos/delete/'); // Ruta para eliminar de favoritos

  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'articulo_id': articleId, // Asegúrate de que este campo coincide con lo que espera tu API
    }),
  );
  print('Respuesta del servidor al eliminar de favoritos: ${response.body}');
  if (response.statusCode == 204) {
    // Código 204 significa que la eliminación fue exitosa (No Content)
    print('Artículo eliminado de favoritos con éxito.');
  } else {
    // Maneja el error si la respuesta no es exitosa
    throw Exception('Error al eliminar de favoritos: ${response.body}');
  }
}


Future<void> toggleFavorito(int articuloId) async {
  final token = await getToken();
  final url = '$baseUrl/favoritos/';

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

//FILTROSSS
Future<List<dynamic>> getArticulosMayorAMenorPrecio() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/precio/mayor/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos de mayor a menor precio: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosMenorAMayorPrecio() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/precio/menor/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos de menor a mayor precio: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosViejoANuevo() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/tiempo/viejo/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos del más viejo al más nuevo: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosNuevoAViejo() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/tiempo/nuevo/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos del más nuevo al más viejo: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosMayorStock() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/stock/mayor/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos de mayor a menor stock: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosMenorStock() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/stock/menor/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos de menor a mayor stock: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosMayorWarranty() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/warranty/mayor/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos con mayor garantía: ${response.body}');
  }
}

Future<List<dynamic>> getArticulosMenorWarranty() async {
  await refreshIfNeeded();
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/warranty/menor/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'] ?? [];
  } else {
    throw Exception('Error al obtener los artículos con menor garantía: ${response.body}');
  }
}

// Función para obtener artículos por nombre
Future<List<dynamic>> getArticuloByName(String name) async {
  await refreshIfNeeded(); // Verifica y refresca el token si es necesario
  final token = await getToken();
  final url = Uri.parse('$baseUrl/articulos/name/$name/'); // Ruta para obtener artículos por nombre

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
      throw Exception('Estructura de respuesta inesperada para los artículos');
    }
  } else {
    throw Exception('Error al obtener los artículos por nombre: ${response.body}');
  }
}

// Función para obtener categorías por nombre
Future<List<dynamic>> getCategoriaByName(String name) async {
  await refreshIfNeeded(); // Verifica y refresca el token si es necesario
  final token = await getToken();
  final url = Uri.parse('$baseUrl/categorias/name/$name/'); // Ruta para obtener categorías por nombre

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  // Imprime la respuesta para depuración
  print('Respuesta del servidor: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    // Si la respuesta es un mapa (categoría individual)
    if (jsonResponse is Map && jsonResponse.containsKey('id')) {
      return [jsonResponse]; // Devuelve una lista con un solo elemento
    } 
    // Si la respuesta es una lista (varias categorías)
    else if (jsonResponse is List) {
      return jsonResponse;
    } 
    // Estructura inesperada
    else {
      throw Exception('Estructura de respuesta inesperada para las categorías');
    }
  } else {
    throw Exception('Error al obtener las categorías por nombre: ${response.body}');
  }
}


}

