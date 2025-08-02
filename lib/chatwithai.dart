import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futureme/model/treemodel.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

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
          {
            "role": "system",
            "content": "You are a compassionate psychoanalyst. Respond in JSON format with 'title' and 'description'. You must analyze the user's emotions and mental state, then give a brief future implication in the description."

          },
          {
            "role": "user",
            "content": message
          }
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
    appBar: AppBar(
      title: const Text('Jarvis Psychoanalysis'),
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                alignment: Alignment.topLeft,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        _response.isNotEmpty
                            ? _response
                            : 'Jarvis is ready. Ask anything...',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type your thoughts...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurple),
                onPressed: () {
                  final input = _controller.text.trim();
                  if (input.isNotEmpty) {
                    sendMessage(input);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget buildTree(TreeNodeData node) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () async {
          if (node.children.isEmpty) {
            final newChild = await getResponseFromAI(node.description);
            setState(() {
              node.children.add(newChild);
            });
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(node.description),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: node.children.map(buildTree).toList(),
        ),
      ),
    ],
  );
}
Future<TreeNodeData> getResponseFromAI(String message) async {
  final url = Uri.parse('http://127.0.0.1:11434/api/chat');

  final res = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "model": "qwen3:8b",
      "messages": [
        {
          "role": "system",
          "content": "You're a psychoanalyst. Respond in JSON with 'title' and 'description'."
        },
        {"role": "user", "content": message}
      ],
      "stream": false
    }),
  );

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final content = data["message"]?["content"] ?? '{}';
    final json = jsonDecode(content);

    return TreeNodeData(
      id: const Uuid().v4(),
      title: json["title"] ?? "No Title",
      description: json["description"] ?? "No Description",
    );
  } else {
    return TreeNodeData(
      id: const Uuid().v4(),
      title: "Error",
      description: "AI returned error: ${res.statusCode}",
    );
  }
}

}
