import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> askAI(String prompt) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:64100/v1'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "model": "qwen2.5", // or "llama2:7b", "qwen:1.8b", etc.
      "prompt": prompt,
      "stream": false
    }),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    return result['response'];
  } else {
    throw Exception('Failed to fetch AI response: ${response.body}');
  }
}
