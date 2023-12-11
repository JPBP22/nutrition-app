import 'package:http/http.dart'
    as http; // Importing the HTTP package for making HTTP requests
import '../secrets.dart'; // Importing a custom file for storing secrets like API keys

// Class for checking the status of a run in a thread using the OpenAI API
class CheckRunStatusService {
  final String _apiKey =
      Secrets.API_KEY; // Retrieving the API key from the secrets file

  // Asynchronous method to check the status of a specific run in a thread
  Future<http.Response> checkRunStatus(String threadId, String runId) async {
    // Constructing the URL for the API request
    var url =
        Uri.parse('https://api.openai.com/v1/threads/$threadId/runs/$runId');
    try {
      // Making a GET request to the API
      var response = await http.get(url, headers: {
        'Authorization':
            'Bearer $_apiKey', // Authorization header with the API key
        'Content-Type': 'application/json', // Content-Type header for JSON data
        'OpenAI-Beta': 'assistants=v1' // OpenAI specific header
      });
      print(
          'CheckRunStatusService Response: ${response.body}'); // Logging the response
      return response; // Returning the response
    } catch (e) {
      print('Error in checkRunStatus: $e'); // Logging any errors
      rethrow; // Rethrowing the error for further handling
    }
  }
}
