import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateThreadService {
  // TODO: Replace with values from .env file in the future
  final String _assistantId = 'id';
  final String _apiKey = 'key';


  Future<http.Response> createThread() async {
    var url = Uri.parse('https://api.openai.com/v1/threads');
    try {
      var response = await http.post(url, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v1'
      });
      print('CreateThreadService Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error in createThread: $e');
      rethrow;
    }
  }
}