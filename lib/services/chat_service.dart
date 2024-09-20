import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatService {
final String baseUrl = 'http://192.168.1.10:8000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Función para enviar el comando y recibir la respuesta del chat
  Future<String> sendChatCommand(String command) async {
    final token = await _storage.read(key: 'access_token');
    final url = Uri.parse('$baseUrl/chat/');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'command': command,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Error al enviar el comando de chat');
    }
  }
}
