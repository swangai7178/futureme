import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({'role': 'user', 'text': message});
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:64100'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "messages": [
          {"role": "user", "content": message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiResponse = data['choices'][0]['message']['content'];
      setState(() {
        messages.add({'role': 'assistant', 'text': aiResponse});
      });
    } else {
      setState(() {
        messages.add({'role': 'assistant', 'text': "⚠️ Failed to get response."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🧠 Jarvis AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage(value.trim());
                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Say something...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      sendMessage(text);
                      _controller.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
