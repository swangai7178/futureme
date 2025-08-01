import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> sendMessage(String message) async {
    setState(() => _loading = true);

    final url = Uri.parse('http://127.0.0.1:11434/api/chat');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "model": "qwen:latest", // or llama3:latest, phi3, etc.
        "messages": [
          {"role": "user", "content": message}
        ],
        "stream": false
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() => _response = data['message']['content']);
    } else {
      setState(() => _response = 'Error: ${res.statusCode}\n${res.body}');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Talk to Jarvis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Say something...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _loading
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            sendMessage(_controller.text);
                          }
                        },
                ),
              ),
              onSubmitted: (text) {
                if (!_loading && text.isNotEmpty) sendMessage(text);
              },
            ),
            SizedBox(height: 24),
            _loading
                ? CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _response,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}