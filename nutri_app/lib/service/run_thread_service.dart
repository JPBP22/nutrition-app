import 'package:http/http.dart' as http;
import 'dart:convert';

class RunThreadService {
  // TODO: Replace with values from .env file in the future
  final String _assistantId = 'id';
  final String _apiKey = 'key'; 
  
  Future<http.Response> runThread(String threadId) async {
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs');
    try {
      var response = await http.post(url, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v1'
      }, body: jsonEncode({
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
