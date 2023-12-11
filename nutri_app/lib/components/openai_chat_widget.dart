import 'package:flutter/material.dart';
import 'dart:convert'; // Importing dart:convert for JSON processing.
import '../service/create_thread_service.dart'; // Importing the Create Thread service.
import '../service/add_user_message_service.dart'; // Importing the Add User Message service.
import '../service/run_thread_service.dart'; // Importing the Run Thread service.
import '../service/check_run_status_service.dart'; // Importing the Check Run Status service.
import '../service/get_messages_service.dart'; // Importing the Get Messages service.
import '../app_theme.dart'; // Importing application theme settings.
import 'save_button.dart'; // Importing the Save button component.
import 'regen_button.dart'; // Importing the Regenerate button component.
import 'package:intl/intl.dart'; // Importing a package for date formatting.
import '../models/message.dart'; // Importing a Message model for chat messages.

// Define a StatefulWidget for the OpenAI chat interface.
class OpenAIChatWidget extends StatefulWidget {
  @override
  _OpenAIChatWidgetState createState() => _OpenAIChatWidgetState();
}

class _OpenAIChatWidgetState extends State<OpenAIChatWidget> {
  // Initializing various services for handling chat functionality.
  final CreateThreadService _createThreadService = CreateThreadService();
  final AddUserMessageService _addUserMessageService = AddUserMessageService();
  final RunThreadService _runThreadService = RunThreadService();
  final CheckRunStatusService _checkRunStatusService = CheckRunStatusService();
  final GetMessagesService _getMessagesService = GetMessagesService();

  final TextEditingController _controller =
      TextEditingController(); // Text editing controller for input field.
  List<Message> messages = []; // List to store chat messages.
  late String threadId; // Variable to store thread ID.
  bool isLoading = false; // Flag to indicate loading state.
  bool isAssistantTyping =
      false; // Flag to indicate if the assistant is typing.

  @override
  void initState() {
    super.initState();
    createThread(); // Create a new chat thread when the widget is initialized.
  }

  // Function to create a new thread for the chat.
  Future<void> createThread() async {
    final createThreadResponse = await _createThreadService.createThread();
    if (createThreadResponse.statusCode == 200) {
      threadId = json.decode(createThreadResponse.body)[
          'id']; // Set thread ID on successful thread creation.
    } else {
      // Handle error in thread creation.
    }
  }

  // Function to send a message in the chat.
  Future<void> sendMessage(String message,
      {bool userInitiated = true, bool addToMessages = true}) async {
    // Add user message to chat if initiated by user and addToMessages is true.
    if (userInitiated && addToMessages) {
      setState(() {
        messages.add(Message('You: $message', DateTime.now()));
        _controller.clear(); // Clear input field after message is sent.
      });
    }

    setState(() {
      isLoading = true; // Set loading to true when sending a message.
      isAssistantTyping = true; // Indicate that the assistant is typing.
    });

    // Send user message and execute thread.
    await _addUserMessageService.addUserMessage(threadId, message);
    final runThreadResponse = await _runThreadService.runThread(threadId);
    if (runThreadResponse.statusCode != 200) {
      // Handle error in running thread.
      setState(() {
        isLoading = false; // Set loading to false on error.
        isAssistantTyping =
            false; // Indicate that the assistant stopped typing.
      });
      return;
    }
    final runId = json.decode(runThreadResponse.body)['id'];

    // Poll for the completion of the assistant's response.
    bool isCompleted = false;
    while (!isCompleted) {
      await Future.delayed(Duration(seconds: 2)); // Polling delay.
      final runStatusResponse =
          await _checkRunStatusService.checkRunStatus(threadId, runId);
      if (runStatusResponse.statusCode == 200) {
        final runStatus = json.decode(runStatusResponse.body);
        if (runStatus['status'] == 'completed') {
          isCompleted = true; // Mark as completed if the response is ready.
          final getMessagesResponse =
              await _getMessagesService.getMessages(threadId);
          if (getMessagesResponse.statusCode == 200) {
            final decodedResponse = json.decode(getMessagesResponse.body);
            List<Message> newMessages = [];
            bool isMenuRegenerated = false; // Flag for menu regeneration.

            // Process the received messages.
            for (var msg in decodedResponse['data']) {
              final content = msg['content'].last['text']['value'];
              if (msg['role'] == 'assistant' && content.isNotEmpty) {
                String assistantText = 'Assistant: $content';

                // Check if the message is a regenerated menu.
                if (content.contains("Here's your new weekly meal plan:")) {
                  isMenuRegenerated = true;
                }

                // Add assistant message to new messages.
                Message assistantMessage =
                    Message(assistantText, DateTime.now());
                newMessages.add(assistantMessage);
              }
            }

            setState(() {
              // Special handling for menu regeneration.
              if (isMenuRegenerated) {
                // Remove old messages related to weekly meal plans.
                var messagesToRemove = messages
                    .where((m) =>
                        m.message.contains("Here's your weekly meal plan:") ||
                        m.message
                            .contains("Here's your new weekly meal plan:") ||
                        m.message.contains('Assistant: Regenerating menu...'))
                    .toList();

                messages.removeWhere((m) => messagesToRemove.contains(m));

                // Add new messages related to the regenerated meal plan.
                for (var newMessage in newMessages) {
                  if (newMessage.message
                      .contains("Here's your new weekly meal plan:")) {
                    if (!messages.contains(newMessage)) {
                      messages.add(Message(newMessage.message, DateTime.now()));
                    }
                  }
                }
              } else {
                // Add new messages to the chat.
                for (var newMessage in newMessages) {
                  if (!messages.contains(newMessage) &&
                      !newMessage.message
                          .contains("Here's your new weekly meal plan:")) {
                    messages.add(Message(newMessage.message, DateTime.now()));
                  }
                }
              }
              isAssistantTyping =
                  false; // Indicate that the assistant stopped typing.
            });
          } else {
            // Handle error in getting messages.
            setState(() {
              messages.add(
                  Message('Error: Failed to get messages.', DateTime.now()));
              isAssistantTyping =
                  false; // Indicate that the assistant stopped typing.
            });
          }
        }
      } else {
        // Handle error in checking run status.
        setState(() {
          messages.add(
              Message('Error: Failed to check run status.', DateTime.now()));
          isAssistantTyping =
              false; // Indicate that the assistant stopped typing.
        });
      }
    }
    setState(() => isLoading = false); // Set loading to false when done.
  }

  // Function to regenerate the menu.
  void regenerateMenu() {
    String uniqueRegenIdentifier =
        "Regen-${DateTime.now().millisecondsSinceEpoch}";

    // Remove old meal plan messages before regenerating.
    setState(() {
      messages.removeWhere((msg) =>
          msg.message.contains("Here's your weekly meal plan:") ||
          msg.message.contains("Here's your new weekly meal plan:"));
    });

    // Find index of last meal plan message to insert regeneration message.
    int regenerateIndex = messages.lastIndexWhere((msg) =>
        msg.message.contains("Here's your weekly meal plan:") ||
        msg.message.contains("Here's your new weekly meal plan:"));

    // Insert regeneration message.
    if (regenerateIndex != -1) {
      setState(() {
        messages.insert(regenerateIndex,
            Message('Assistant: Regenerating menu...', DateTime.now()));
      });
    } else {
      setState(() {
        messages
            .add(Message('Assistant: Regenerating menu...', DateTime.now()));
      });
    }

    // Send message to regenerate the menu.
    sendMessage(
        "Please regenerate the menu, identifier: $uniqueRegenIdentifier",
        userInitiated: false,
        addToMessages: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.isNotEmpty ? messages.length : 1,
              itemBuilder: (context, index) {
                if (messages.isEmpty) {
                  // Display a welcome message when there are no messages in the chat.
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 5.0, right: 16.0, left: 16.0, top: 200.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.eco, // Display an eco-friendly icon.
                            size: 100.0,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Hello! Im your personal nutritionist.\nWe will develop a weekly meal plan specialized just for you!\nGive me some details about your weight, height, sex, activity level, and your goals.',
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Determine the type of message for styling.
                  bool isUserMessage =
                      messages[index].message.startsWith('You: ');
                  bool isWeeklyMenuMessage = messages[index]
                          .message
                          .contains("Here's your weekly meal plan:") ||
                      messages[index]
                          .message
                          .contains("Here's your new weekly meal plan:");
                  DateTime timestamp = messages[index].timestamp;

                  // Render each message in the chat.
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                    child: Column(
                      children: [
                        Align(
                          // Align message to left or right based on sender.
                          alignment: isUserMessage
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            // Styling for message bubble.
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8),
                            child: Column(
                              crossAxisAlignment: isUserMessage
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messages[index].message,
                                  style: AppTheme.darkTextTheme.bodyLarge,
                                  textAlign: isUserMessage
                                      ? TextAlign.right
                                      : TextAlign.left,
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  DateFormat('hh:mm a').format(
                                      timestamp), // Show the time of the message.
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(
                                bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? Color.fromARGB(255, 30, 148, 245)
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        // Display Save and Regenerate buttons for weekly menu messages.
                        if (isWeeklyMenuMessage)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SaveButton(
                                    menuMessage: messages[index].message),
                                RegenButton(onRegenerate: regenerateMenu),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          // Display a loading indicator when the assistant is typing.
          if (isAssistantTyping &&
              !messages.any((msg) =>
                  msg.message.contains('Assistant: Regenerating menu...')))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text('Assistant is typing...')
                ],
              ),
            ),
          // Text input field for sending new messages.
          Padding(
            padding:
                const EdgeInsets.only(bottom: 16.0, right: 16.0, left: 16.0),
            child: TextField(
              controller: _controller, // Controller for the text field.
              decoration: InputDecoration(
                labelText: 'Type your message', // Label for the input field.
                prefixIcon:
                    const Icon(Icons.message), // Icon for the input field.
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(
                      _controller.text), // Send message on button press.
                ),
              ),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }
}
