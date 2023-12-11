import 'package:http/http.dart' as http;
import 'dart:convert';
import '../secrets.dart';

class RunThreadService {
  final String _apiKey = Secrets.API_KEY;
  final String _assistantId = Secrets.ASSISTANT_JSON_ID;

  Future<http.Response> runThread(String threadId) async {
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs');
    try {
      var response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'OpenAI-Beta': 'assistants=v1'
          },
          body: jsonEncode({
            'assistant_id': _assistantId,
          }));
      print('RunThreadService Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error in runThread: $e');
      rethrow;
    }
  }
}
