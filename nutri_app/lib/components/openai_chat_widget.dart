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
  final RetrieveRunStepsService _retrieveRunStepsService = RetrieveRunStepsService();
  final GetMessagesService _getMessagesService = GetMessagesService();

  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  Future<void> sendMessage() async {
    final message = _controller.text;
    _controller.clear();
    setState(() => messages.add('You: $message'));

    final createThreadResponse = await _createThreadService.createThread();
    if (createThreadResponse.statusCode != 200) {
      // Handle error
      return;
    }
    final threadId = json.decode(createThreadResponse.body)['id'];

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
            // Process and display messages
            final List<dynamic> messageData = decodedResponse['data'];
            for (var msg in messageData) {
              final content = msg['content'][0]['text']['value'];
              if (msg['role'] == 'assistant' && content.isNotEmpty) {
                setState(() => messages.add('Assistant: $content'));
              }
            }
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
              itemBuilder: (context, index) => ListTile(title: Text(messages[index])),
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
