import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/create_thread_service.dart';
import '../service/add_user_message_service.dart';
import '../service/run_thread_service.dart';
import '../service/check_run_status_service.dart';
import '../service/get_messages_service.dart';
import '../app_theme.dart';
import 'save_button.dart'; // Importing the Save button component
import 'regen_button.dart'; // Importing the Regenerate button component
import 'package:intl/intl.dart';
import '../models/message.dart';

class OpenAIChatWidget extends StatefulWidget {
  @override
  _OpenAIChatWidgetState createState() => _OpenAIChatWidgetState();
}

class _OpenAIChatWidgetState extends State<OpenAIChatWidget> {
  final CreateThreadService _createThreadService = CreateThreadService();
  final AddUserMessageService _addUserMessageService = AddUserMessageService();
  final RunThreadService _runThreadService = RunThreadService();
  final CheckRunStatusService _checkRunStatusService = CheckRunStatusService();
  final GetMessagesService _getMessagesService = GetMessagesService();

  final TextEditingController _controller = TextEditingController();
  List<Message> messages = [];
  late String threadId;
  bool isLoading = false;
  bool isAssistantTyping = false; // New state variable

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
        messages.add(Message('You: $message', DateTime.now()));
        _controller.clear();
      });
    }

    setState(() {
      isLoading = true;
      isAssistantTyping = true; // Assistant starts typing
    });

    await _addUserMessageService.addUserMessage(threadId, message);
    final runThreadResponse = await _runThreadService.runThread(threadId);
    if (runThreadResponse.statusCode != 200) {
      // Handle error
      setState(() {
        isLoading = false;
        isAssistantTyping = false; // Assistant stops typing
      });
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
            List<Message> newMessages = [];
            bool isMenuRegenerated = false;

            for (var msg in decodedResponse['data']) {
              final content = msg['content'].last['text']['value'];
              if (msg['role'] == 'assistant' && content.isNotEmpty) {
                String assistantText = 'Assistant: $content';

                // Check if the message is a regenerated menu
                if (content.contains("Here's your new weekly meal plan:")) {
                  isMenuRegenerated = true;
                }

                Message assistantMessage = Message(assistantText, DateTime.now());
                newMessages.add(assistantMessage);
              }
            }

            setState(() {
              if (isMenuRegenerated) {
                var messagesToRemove = messages
                    .where((m) =>
                        m.message.contains("Here's your weekly meal plan:") ||
                        m.message.contains("Here's your new weekly meal plan:") ||
                        m.message.contains('Assistant: Regenerating menu...'))
                    .toList();

                messages.removeWhere((m) => messagesToRemove.contains(m));

                for (var newMessage in newMessages) {
                  if (newMessage.message
                      .contains("Here's your new weekly meal plan:")) {
                    if (!messages.contains(newMessage)) {
                      messages.add(Message(newMessage.message, DateTime.now()));
                    }
                  }
                }
              } else {
                for (var newMessage in newMessages) {
                  if (!messages.contains(newMessage) &&
                      !newMessage.message
                          .contains("Here's your new weekly meal plan:")) {
                    messages.add(Message(newMessage.message, DateTime.now()));
                  }
                }
              }
              isAssistantTyping = false; // Assistant stops typing
            });
          } else {
            setState(() {
              messages.add(Message('Error: Failed to get messages.', DateTime.now()));
              isAssistantTyping = false; // Assistant stops typing
            });
          }
        }
      } else {
        setState(() {
          messages.add(Message('Error: Failed to check run status.', DateTime.now()));
          isAssistantTyping = false; // Assistant stops typing
        });
      }
    }
    setState(() => isLoading = false);
  }

  void regenerateMenu() {
    String uniqueRegenIdentifier =
        "Regen-${DateTime.now().millisecondsSinceEpoch}";

    setState(() {
      messages.removeWhere((msg) =>
          msg.message.contains("Here's your weekly meal plan:") ||
          msg.message.contains("Here's your new weekly meal plan:"));
    });

    int regenerateIndex = messages.lastIndexWhere((msg) =>
        msg.message.contains("Here's your weekly meal plan:") ||
        msg.message.contains("Here's your new weekly meal plan:"));

    if (regenerateIndex != -1) {
      setState(() {
        messages.insert(regenerateIndex, Message('Assistant: Regenerating menu...', DateTime.now()));
      });
    } else {
      setState(() {
        messages.add(Message('Assistant: Regenerating menu...', DateTime.now()));
      });
    }

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
                      padding: const EdgeInsets.only(
                          bottom: 5.0, right: 16.0, left: 16.0, top: 200.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons
                                .eco, // Use a relevant icon, in this case, 'eco' for leaf
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
                  bool isUserMessage = messages[index].message.startsWith('You: ');
                  bool isWeeklyMenuMessage = messages[index].
                          message.contains("Here's your weekly meal plan:") ||
                      messages[index].
                          message.contains("Here's your new weekly meal plan:");
                  DateTime timestamp = messages[index].timestamp;
                  return Padding(
                    padding: const EdgeInsets.only(
                    bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                            ),
                            child: Column(
                              crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  messages[index].message,
                                  style: AppTheme.darkTextTheme.bodyLarge,
                                  textAlign: isUserMessage ? TextAlign.right : TextAlign.left,
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  DateFormat('hh:mm a').format(timestamp),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            padding: const EdgeInsets.only(
                                bottom: 5.0, right: 16.0, left: 16.0, top: 5.0),
                            decoration: BoxDecoration(
                                color: isUserMessage ? Color.fromARGB(255, 30, 148, 245) : Colors.grey[800],
                                borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        if (isWeeklyMenuMessage)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SaveButton(menuMessage: messages[index].message),
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
          if (isAssistantTyping &&
              !messages.any(
                  (msg) => msg.message.contains('Assistant: Regenerating menu...')))
            const Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text('Assistant is typing...')
                ],
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
