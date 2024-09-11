import 'package:flutter/material.dart';
import 'package:flutter_app/services/chat_service.dart';

class ChatbootScreen extends StatefulWidget {
  @override
  _ChatbootScreenState createState() => _ChatbootScreenState();
}

class _ChatbootScreenState extends State<ChatbootScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Función para enviar el mensaje al chat
  void _sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
    });

    try {
      final response = await _chatService.sendChatCommand(message);
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages
            .add({'role': 'assistant', 'content': 'Error: ${e.toString()}'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple, // Color de fondo del AppBar
      ),
      backgroundColor: Colors.grey[200], // Fondo general de la pantalla
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUserMessage = message['role'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.purple[300]
                          : Colors.purple[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft:
                            isUserMessage ? Radius.circular(12) : Radius.zero,
                        bottomRight:
                            isUserMessage ? Radius.zero : Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: isUserMessage ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Campo de texto estilizado
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                // Botón de envío estilizado
                GestureDetector(
                  onTap: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _controller.clear();
                    }
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
