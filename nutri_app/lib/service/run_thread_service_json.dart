import 'package:http/http.dart'
    as http; // Importing the HTTP package for making HTTP requests.
import 'dart:convert'; // Importing Dart's convert library for JSON encoding and decoding.
import '../secrets.dart'; // Importing a file that contains secret keys and other confidential data.

// Class responsible for running a thread using the OpenAI API.
class RunThreadService {
  final String _apiKey =
      Secrets.API_KEY; // Retrieving the API key from the secrets file.
  final String _assistantId = Secrets
      .ASSISTANT_JSON_ID; // Retrieving the assistant ID from the secrets file.

  // Asynchronous method to run a specific thread.
  Future<http.Response> runThread(String threadId) async {
    // Constructing the URL for the API request to run a thread.
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs');
    try {
      // Making a POST request to the OpenAI API to run the thread.
      var response = await http.post(url,
          headers: {
            'Authorization':
                'Bearer $_apiKey', // Setting the Authorization header with the API key.
            'Content-Type':
                'application/json', // Specifying the content type as JSON.
            'OpenAI-Beta':
                'assistants=v1' // Specific header for OpenAI API usage.
          },
          body: jsonEncode({
            'assistant_id':
                _assistantId, // Including the assistant ID in the request body.
          }));
      print(
          'RunThreadService Response: ${response.body}'); // Logging the API response.
      return response; // Returning the HTTP response.
    } catch (e) {
      print(
          'Error in runThread: $e'); // Logging any errors encountered during the API call.
      rethrow; // Rethrowing the error for further handling.
    }
  }
}
