import 'package:http/http.dart'
    as http; // Importing the HTTP package to make HTTP requests.
import 'dart:convert'; // Importing Dart's convert library for JSON processing.
import '../secrets.dart'; // Importing a file that contains secret keys and other sensitive data.

// Class for running a thread using the OpenAI API.
class RunThreadService {
  final String _apiKey =
      Secrets.API_KEY; // Storing the API key from the Secrets file.
  final String _assistantId =
      Secrets.ASSISTANT_ID; // Storing the assistant ID from the Secrets file.

  // Asynchronous method to run a specific thread.
  Future<http.Response> runThread(String threadId) async {
    // Constructing the URL for the API request to run a thread.
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/runs');
    try {
      // Making a POST request to the OpenAI API to run the thread.
      var response = await http.post(url,
          headers: {
            'Authorization':
                'Bearer $_apiKey', // Authorization header with the API key.
            'Content-Type':
                'application/json', // Content-Type header for JSON data.
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
