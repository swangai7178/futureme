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
  final List<TreeNodeData> rootNodes = [];
 
  

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🧠 Psychoanalysis Tree')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your concern...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      _controller.clear();
                      await handleUserMessage(text);
                    }
                  },
                  child: Text('Ask'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: rootNodes.map((node) => buildTree(node)).toList(),
            ),
          ),
        ],
      ),
    );
  }

 Widget buildTree(TreeNodeData node, {double indent = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.deepPurple[50],
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(node.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(node.description),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  final text = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      final c = TextEditingController();
                      return AlertDialog(
                        title: Text('Ask further...'),
                        content: TextField(controller: c),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, null),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, c.text),
                            child: Text('Ask'),
                          ),
                        ],
                      );
                    },
                  );
                  if (text != null && text.trim().isNotEmpty) {
                    await handleUserMessage(text.trim(), node);
                  }
                },
              ),
            ),
          ),
          ...node.children.map((child) => buildTree(child, indent: indent + 20)),
        ],
      ),
    );
  }

Future<void> handleUserMessage(String message, [TreeNodeData? parent]) async {
    final newNode = await getResponseFromAI(message);
    setState(() {
      if (parent == null) {
        rootNodes.add(newNode);
      } else {
        parent.children = List<TreeNodeData>.from(parent.children)..add(newNode);
      }
    });
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
      print(content);
       final cleaned = content.replaceAll(RegExp(r"<think>[\s\S]*?</think>"), "").trim();
      final json = jsonDecode(cleaned);
    print("AI Response: $json");

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
