import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RetrieveRunStepsService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;

  Future<http.Response> retrieveRunSteps(String threadId, String runId) async {
    var url = Uri.parse(
        'https://api.openai.com/v1/threads/$threadId/runs/$runId/steps');
    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v1'
      });
      print('RetrieveRunStepsService Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error in retrieveRunSteps: $e');
      rethrow;
    }
  }
}
