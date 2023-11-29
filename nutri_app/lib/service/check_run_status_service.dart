import 'package:http/http.dart' as http;

class CheckRunStatusService {
  // TODO: Replace with values from .env file in the future
  final String _apiKey = 'key';


  Future<http.Response> checkRunStatus(String threadId, String runId) async {
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs/$runId');
    try {
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'OpenAI-Beta': 'assistants=v1'
      });
      print('CheckRunStatusService Response: ${response.body}');
      return response;
    } catch (e) {
      print('Error in checkRunStatus: $e');
      rethrow;
    }
  }
}