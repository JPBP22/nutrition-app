import 'package:http/http.dart' as http;
import '../secrets.dart';

class CreateThreadService {
  final String _apiKey = Secrets.API_KEY;

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
