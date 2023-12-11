import 'package:http/http.dart'
    as http; // Importing the HTTP package for making HTTP requests
import 'dart:convert'; // Importing Dart's convert library for JSON processing
import '../secrets.dart'; // Importing a custom file for storing secrets like API keys

// Class for adding a user message to a thread using the OpenAI API
class AddUserMessageService {
  final String _apiKey =
      Secrets.API_KEY; // Retrieving the API key from the secrets file

  // Asynchronous method to add a user message to a specific thread
  Future<http.Response> addUserMessage(String threadId, String message) async {
    // Constructing the URL for the API request
    var url = Uri.parse('https://api.openai.com/v1/threads/$threadId/messages');
    try {
      // Making a POST request to the API
      var response = await http.post(url,
          headers: {
            'Authorization':
                'Bearer $_apiKey', // Authorization header with the API key
            'Content-Type':
                'application/json', // Content-Type header for JSON data
            'OpenAI-Beta': 'assistants=v1' // OpenAI specific header
          },
          body: jsonEncode({
            'role': 'user', // Specifying the role as 'user'
            'content': message, // The message content
          }));
      print(
          'AddUserMessageService Response: ${response.body}'); // Logging the response
      return response; // Returning the response
    } catch (e) {
      print('Error in addUserMessage: $e'); // Logging any errors
      rethrow; // Rethrowing the error for further handling
    }
  }
}
