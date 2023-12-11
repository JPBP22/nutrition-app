import 'package:http/http.dart'
    as http; // Importing the HTTP package to enable HTTP requests.
import '../secrets.dart'; // Importing a file that contains secret keys and credentials.

// Class responsible for creating a new thread using the OpenAI API.
class CreateThreadService {
  final String _apiKey =
      Secrets.API_KEY; // Storing the API key from the Secrets file.

  // Asynchronous method to create a new thread.
  Future<http.Response> createThread() async {
    // The URL for the OpenAI API endpoint to create a new thread.
    var url = Uri.parse('https://api.openai.com/v1/threads');
    try {
      // Making a POST request to the OpenAI API to create a thread.
      var response = await http.post(url, headers: {
        'Authorization':
            'Bearer $_apiKey', // Setting the Authorization header with the API key.
        'Content-Type':
            'application/json', // Specifying the content type as JSON.
        'OpenAI-Beta': 'assistants=v1' // Specific header for OpenAI API usage.
      });
      print(
          'CreateThreadService Response: ${response.body}'); // Logging the API response.
      return response; // Returning the HTTP response.
    } catch (e) {
      print(
          'Error in createThread: $e'); // Logging any errors encountered during the API call.
      rethrow; // Rethrowing the error for further handling.
    }
  }
}
