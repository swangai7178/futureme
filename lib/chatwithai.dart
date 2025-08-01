import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> sendMessage(String message) async {
    setState(() {
      _loading = true;
      _response = '';
    });

    final url = Uri.parse('http://127.0.0.1:11434/api/chat');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "qwen3:8b",
          "messages": [
            {"role": "user", "content": message}
          ],
          "stream": false
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final content = data["message"]?["content"] ?? "No response from Jarvis.";
        setState(() => _response = content);
      } else {
        setState(() => _response = 'Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      setState(() => _response = 'Exception: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Talk to Jarvis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Say something...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
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
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _response,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
