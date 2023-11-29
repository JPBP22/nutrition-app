import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GetMessagesService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;

  Future<http.Response> getMessages(String threadId) async {
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/messages');
    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v1'
      });
      print('GetMessagesService Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error in getMessages: $e');
      rethrow;
    }
  }
}
