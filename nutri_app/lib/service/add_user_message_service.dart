import 'package:http/http.dart' as http;
import 'dart:convert';

class AddUserMessageService {
  // TODO: Replace with values from .env file in the future
  final String _apiKey = 'key';

  Future<http.Response> addUserMessage(String threadId, String message) async {
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/messages');
    try {
      var response = await http.post(url, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v1'
      }, body: jsonEncode({
        'role': 'user',
        'content': message,
      }));
      print('AddUserMessageService Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error in addUserMessage: $e');
      rethrow;
    }
  }
}