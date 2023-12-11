import 'package:flutter/material.dart';
import 'dart:convert'; // Importing for JSON processing.
import '../service/create_thread_service.dart'; // Importing the service class to create a new thread.
import '../service/add_user_message_service.dart'; // Importing the service class to add a user message.
import '../service/run_thread_service_json.dart'; // Importing the service class to run the thread.
import '../service/check_run_status_service.dart'; //  Importing the service class to check the run status.
import '../service/get_messages_service.dart'; // Importing the service class to get the messages.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firebase Firestore for database operations.
import 'package:firebase_auth/firebase_auth.dart'; // Importing Firebase Authentication for user management.

// Define a StatefulWidget for the Save button. This allows the button to maintain its own state.
class SaveButton extends StatefulWidget {
  final String menuMessage; // Property to hold the menu message to be saved.

  // Constructor for SaveButton, taking a required menuMessage and an optional key.
  SaveButton({Key? key, required this.menuMessage}) : super(key: key);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool isSaving =
      false; // State variable to track if the button is in the process of saving.

  @override
  Widget build(BuildContext context) {
    return isSaving
        ? const CircularProgressIndicator() // Show progress indicator if saving is in progress.
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                isSaving = true; // Indicate the start of the saving process.
              });

              // Show a SnackBar to inform the user that the menu generation is in progress.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'The AI assistant is generating your weekly menu...'),
                  backgroundColor: Colors.green,
                ),
              );

              // Prompt the user to enter a name for the menu.
              final dialogContext =
                  Navigator.of(context, rootNavigator: true).context;
              String menuName = await showDialog(
                context: dialogContext,
                builder: (dialogContext) => Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enter a name for the menu:'),
                      TextField(
                        onSubmitted: (value) =>
                            Navigator.pop(dialogContext, value),
                      ),
                    ],
                  ),
                ),
              );
              _handleSave(context,
                  menuName); // Call the method to handle the save operation.
            },
            child: const Text('Save Menu'),
          );
  }

  // Method to handle the save operation.
  void _handleSave(BuildContext context, String menuName) async {
    try {
      // Creating a new thread and adding a user message.
      final createThreadResponse = await CreateThreadService().createThread();
      if (createThreadResponse.statusCode != 200) {
        throw Exception('Failed to create thread');
      }
      final threadId = json.decode(createThreadResponse.body)['id'];

      await AddUserMessageService()
          .addUserMessage(threadId, widget.menuMessage);
      final runThreadResponse = await RunThreadService().runThread(threadId);

      if (runThreadResponse.statusCode != 200) {
        throw Exception('Failed to run thread');
      }
      final runId = json.decode(runThreadResponse.body)['id'];

      // Wait for the response to be completed before proceeding.
      await _waitForResponse(threadId, runId, context, menuName);
    } catch (e) {
      // Show error message in case of failure.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSaving = false; // Indicate the end of the saving process.
      });

      // Show a success message upon completion.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu has been successfully saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Method to wait for the response from the server.
  Future<void> _waitForResponse(String threadId, String runId,
      BuildContext context, String menuName) async {
    bool isCompleted = false;
    while (!isCompleted) {
      await Future.delayed(
          Duration(seconds: 2)); // Poll for response every 2 seconds.
      final runStatusResponse =
          await CheckRunStatusService().checkRunStatus(threadId, runId);
      if (runStatusResponse.statusCode != 200) {
        throw Exception('Failed to check run status');
      }
      final runStatus = json.decode(runStatusResponse.body);
      if (runStatus['status'] == 'completed') {
        isCompleted = true;
        final getMessagesResponse =
            await GetMessagesService().getMessages(threadId);
        if (getMessagesResponse.statusCode != 200) {
          throw Exception('Failed to get messages');
        }
        final jsonResponse = json.decode(getMessagesResponse.body);

        // Saving the response to Firebase Firestore.
        String userId = FirebaseAuth.instance.currentUser!.uid;
        CollectionReference menus = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('menus');

        print('Menu Name: $menuName'); // Debug print statement.

        // Add the menu to the Firestore collection.
        menus.add({
          'menu': jsonResponse,
          'created_at': DateTime.now(),
          'name': menuName,
        });
      }
    }
  }
}
