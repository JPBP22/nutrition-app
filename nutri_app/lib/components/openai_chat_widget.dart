import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/create_thread_service.dart';
import '../service/add_user_message_service.dart';
import '../service/run_thread_service.dart';
import '../service/check_run_status_service.dart';
import '../service/retrieve_run_steps_service.dart';
import '../service/get_messages_service.dart';
import '../app_theme.dart';
import 'save_button.dart'; // Importing the Save button component
import 'regen_button.dart'; // Importing the Regenerate button component

class OpenAIChatWidget extends StatefulWidget {
  @override
  _OpenAIChatWidgetState createState() => _OpenAIChatWidgetState();
}

class _OpenAIChatWidgetState extends State<OpenAIChatWidget> {
  final CreateThreadService _createThreadService = CreateThreadService();
  final AddUserMessageService _addUserMessageService = AddUserMessageService();
  final RunThreadService _runThreadService = RunThreadService();
  final CheckRunStatusService _checkRunStatusService = CheckRunStatusService();
  final RetrieveRunStepsService _retrieveRunStepsService = RetrieveRunStepsService();
  final GetMessagesService _getMessagesService = GetMessagesService();

  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  late String threadId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    createThread();
  }

  Future<void> createThread() async {
    final createThreadResponse = await _createThreadService.createThread();
    if (createThreadResponse.statusCode == 200) {
      threadId = json.decode(createThreadResponse.body)['id'];
    } else {
      // Handle error
    }
  }

  Future<void> sendMessage(String message, {bool userInitiated = true}) async {
    if (userInitiated) {
      _controller.clear();
      setState(() => messages.add('You: $message'));
    } else {
      // Find the index of the last weekly menu message and update it
      int menuIndex = messages.lastIndexWhere((msg) => msg.contains("Here's your weekly meal plan:") || msg.contains("Here's your new weekly meal plan:"));
      if (menuIndex != -1) {
        setState(() {
          messages[menuIndex] = 'Assistant: Regenerating menu!';
        });
      }
    }

    setState(() => isLoading = true);

    await _addUserMessageService.addUserMessage(threadId, message);
    final runThreadResponse = await _runThreadService.runThread(threadId);
    if (runThreadResponse.statusCode != 200) {
      // Handle error
      return;
    }
    final runId = json.decode(runThreadResponse.body)['id'];

    bool isCompleted = false;
    while (!isCompleted) {
      await Future.delayed(Duration(seconds: 2)); // Polling delay
      final runStatusResponse = await _checkRunStatusService.checkRunStatus(threadId, runId);
      if (runStatusResponse.statusCode == 200) {
        final runStatus = json.decode(runStatusResponse.body);
        if (runStatus['status'] == 'completed') {
          isCompleted = true;
          final getMessagesResponse = await _getMessagesService.getMessages(threadId);
          if (getMessagesResponse.statusCode == 200) {
            final decodedResponse = json.decode(getMessagesResponse.body);
            List<String> newMessages = [];
            for (var msg in decodedResponse['data']) {
              final content = msg['content'].last['text']['value'];
              if (msg['role'] == 'user') {
                newMessages.add('You: $content');
              } else if (msg['role'] == 'assistant' && content.isNotEmpty) {
                newMessages.add('Assistant: $content');
              }
            }

            setState(() {
              // Replace the "Regenerating menu!" message with the new menu
              int regenerateIndex = messages.indexWhere((msg) => msg == 'Assistant: Regenerating menu!');
              if (regenerateIndex != -1) {
                messages[regenerateIndex] = newMessages.last;
              } else {
                messages.clear();
                messages.addAll(newMessages.reversed);
              }
            });
          } else {
            // Handle error in getting messages
            setState(() => messages.add('Error: Failed to get messages.'));
          }
        }
      } else {
        // Handle error in checking run status
        setState(() => messages.add('Error: Failed to check run status.'));
        break;
      }
    }
    setState(() => isLoading = false);
  }

  void regenerateMenu() {
    sendMessage("Please regenerate the menu", userInitiated: false);
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
                  // Your existing code for the empty message state
                  // ...
                } else {
                  bool isWeeklyMenuMessage = messages[index].contains("Here's your weekly meal plan:") || messages[index].contains("Here's your new weekly meal plan:");
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                    child: Column(
                      children: [
                        Container(
                          child: ListTile(title: Text(messages[index], style: AppTheme.darkTextTheme.bodyText1)),
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          padding: const EdgeInsets.only(bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                          decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8.0)),
                        ),
                        if (isWeeklyMenuMessage)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SaveButton(onSave: () {
                                // TODO: Implement save functionality
                              }),
                              RegenButton(onRegenerate: regenerateMenu),
                            ],
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 16.0, left: 16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Type your message',
                prefixIcon: const Icon(Icons.message),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
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
