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
  final RetrieveRunStepsService _retrieveRunStepsService =
      RetrieveRunStepsService();
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

  Future<void> sendMessage(String message,
      {bool userInitiated = true, bool addToMessages = true}) async {
    if (userInitiated && addToMessages) {
      setState(() {
        messages.add('You: $message');
        _controller.clear();
      });
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
      final runStatusResponse =
          await _checkRunStatusService.checkRunStatus(threadId, runId);
      if (runStatusResponse.statusCode == 200) {
        final runStatus = json.decode(runStatusResponse.body);
        if (runStatus['status'] == 'completed') {
          isCompleted = true;
          final getMessagesResponse =
              await _getMessagesService.getMessages(threadId);
          if (getMessagesResponse.statusCode == 200) {
            final decodedResponse = json.decode(getMessagesResponse.body);
            List<String> newMessages = [];
            bool isMenuRegenerated = false;

            for (var msg in decodedResponse['data']) {
              final content = msg['content'].last['text']['value'];
              if (msg['role'] == 'assistant' && content.isNotEmpty) {
                String assistantMessage = 'Assistant: $content';

                // Check if the message is a regenerated menu
                if (content.contains("Here's your new weekly meal plan:")) {
                  isMenuRegenerated = true;
                }

                newMessages.add(assistantMessage);
              }
            }

            setState(() {
              if (isMenuRegenerated) {
                // Collect messages to be removed in a separate list
                var messagesToRemove = messages
                    .where((m) =>
                        m.contains("Here's your weekly meal plan:") ||
                        m.contains("Here's your new weekly meal plan:") ||
                        m.contains('Assistant: Regenerating menu...'))
                    .toList();

                // Remove the collected messages
                messages.removeWhere((m) => messagesToRemove.contains(m));

                // Add only the new menu messages
                for (var newMessage in newMessages) {
                  if (newMessage
                      .contains("Here's your new weekly meal plan:")) {
                    if (!messages.contains(newMessage)) {
                      messages.add(newMessage);
                    }
                  }
                }
              } else {
                // Add new messages if they are not already in the list and not related to the menu
                for (var newMessage in newMessages) {
                  if (!messages.contains(newMessage) &&
                      !newMessage
                          .contains("Here's your new weekly meal plan:")) {
                    messages.add(newMessage);
                  }
                }
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
    String uniqueRegenIdentifier =
        "Regen-${DateTime.now().millisecondsSinceEpoch}";

    // Remove the old menu immediately when regeneration is requested
    setState(() {
      messages.removeWhere((msg) =>
          msg.contains("Here's your weekly meal plan:") ||
          msg.contains("Here's your new weekly meal plan:"));
    });

    // Find the last menu message index for potential placeholder placement
    int regenerateIndex = messages.lastIndexWhere((msg) =>
        msg.contains("Here's your weekly meal plan:") ||
        msg.contains("Here's your new weekly meal plan:"));

    if (regenerateIndex != -1) {
      // Place the placeholder at the position of the old menu
      setState(() {
        messages.insert(regenerateIndex, 'Assistant: Regenerating menu...');
      });
    } else {
      // If no old menu is found, append the placeholder at the end
      setState(() {
        messages.add('Assistant: Regenerating menu...');
      });
    }

    // Send the message to regenerate the menu without adding it to the messages list
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
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: 5.0, right: 16.0, left: 16.0, top: 200.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons
                                .eco, // Use a relevant icon, in this case, 'eco' for leaf
                            size: 100.0,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16.0),
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
                  bool isWeeklyMenuMessage = messages[index]
                          .contains("Here's your weekly meal plan:") ||
                      messages[index]
                          .contains("Here's your new weekly meal plan:");
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                    child: Column(
                      children: [
                        Container(
                          child: ListTile(
                              title: Text(messages[index],
                                  style: AppTheme.darkTextTheme.bodyText1)),
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          padding: const EdgeInsets.only(
                              bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8.0)),
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
            padding:
                const EdgeInsets.only(bottom: 16.0, right: 16.0, left: 16.0),
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
