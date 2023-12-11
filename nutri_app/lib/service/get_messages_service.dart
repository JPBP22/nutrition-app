import 'package:http/http.dart'
    as http; // Importing the http package for making HTTP requests.
import '../secrets.dart'; // Importing a file that contains secret keys and credentials.

// Class for retrieving messages from a thread using the OpenAI API.
class GetMessagesService {
  final String _apiKey =
      Secrets.API_KEY; // Storing the API key from the Secrets file.

  // Asynchronous method to get messages from a specific thread.
  Future<http.Response> getMessages(String threadId) async {
    // Constructing the URL for the API request to get messages from a specific thread.
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/messages');
    try {
      // Making a GET request to the OpenAI API to retrieve messages.
      var response = await http.get(url, headers: {
        'Authorization':
            'Bearer $_apiKey', // Setting the Authorization header with the API key.
        'Content-Type':
            'application/json', // Specifying the content type as JSON.
        'OpenAI-Beta': 'assistants=v1' // Specific header for OpenAI API usage.
      });
      print(
          'GetMessagesService Response: ${response.body}'); // Logging the API response.
      return response; // Returning the HTTP response.
    } catch (e) {
      print(
          'Error in getMessages: $e'); // Logging any errors encountered during the API call.
      rethrow; // Rethrowing the error for further handling.
    }
  }
}
