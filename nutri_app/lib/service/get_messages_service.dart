import 'package:http/http.dart' as http;

class GetMessagesService {
  // TODO: Replace with values from .env file in the future
  final String _apiKey = 'key';

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