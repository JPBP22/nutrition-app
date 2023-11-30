import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/create_thread_service.dart';
import '../service/add_user_message_service.dart';
import '../service/run_thread_service.dart';
import '../service/check_run_status_service.dart';
import '../service/retrieve_run_steps_service.dart';
import '../service/get_messages_service.dart';

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

  bool isLoading = false; // Add this line to track loading state

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

  Future<void> sendMessage() async {
    final message = _controller.text;
    _controller.clear();
    setState(() => messages.add('You: $message'));

    // Add a placeholder message before starting the loading
    setState(() {
      isLoading = true;
      messages.add('Assistant: typing...');
    });

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
            // Process and display messages
            final List<dynamic> messageData = decodedResponse['data'];
            // Clear existing messages before adding new ones
            setState(() => messages.clear());
            for (var msg in messageData) {
              final content = msg['content'].last['text']['value'];
              if (msg['role'] == 'user') {
                setState(() => messages.add('You: $content'));
              } else if (msg['role'] == 'assistant' && content.isNotEmpty) {
                setState(() => messages.add('Assistant: $content'));
              }
            }

            // Reverse the order of messages before updating the state
            setState(() => messages = messages.reversed.toList());
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
    setState(() => isLoading = false); // Add this line to track loading state
    // Replace the placeholder message with the actual assistant message
    if (!isLoading) {
      setState(() {
        int index = messages.indexOf('Assistant: typing...');
        if (index != -1) {
          String content = messages.last.split('Assistant: ')[1];
          messages[index] =
              'Assistant: $content'; // Replace the placeholder with the actual message
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OpenAI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                String message = messages[index];
                return ListTile(title: Text(message));
              },
            ),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Type your message',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
