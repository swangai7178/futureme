import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<Map<String, String>> messages = []; // {'role': 'user/ai', 'text': ...}
  final TextEditingController _controller = TextEditingController();
  bool loading = false;

  Future<void> sendMessage(String prompt) async {
    setState(() {
      messages.add({'role': 'user', 'text': prompt});
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:64100'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "qwen2.5", // change this based on model
          "prompt": prompt,
          "stream": false
        }),
      );

      final data = jsonDecode(response.body);
      setState(() {
        messages.add({'role': 'ai', 'text': data['response'] ?? 'No response.'});
        loading = false;
      });
    } catch (e) {
      setState(() {
        messages.add({'role': 'ai', 'text': '⚠️ Error: $e'});
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ask AI for Guidance")),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Ask a question..."),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        sendMessage(text.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      sendMessage(text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
