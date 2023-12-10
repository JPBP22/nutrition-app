import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/create_thread_service.dart';
import '../service/add_user_message_service.dart';
import '../service/run_thread_service_json.dart';
import '../service/check_run_status_service.dart';
import '../service/get_messages_service.dart';
import '../screens/dishes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveButton extends StatefulWidget {
  final String menuMessage;

  SaveButton({Key? key, required this.menuMessage}) : super(key: key);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleSave(context),
      child: Text('Save Menu'),
    );
  }

  void _handleSave(BuildContext context) async {
    try {
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

      await _waitForResponse(threadId, runId, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _waitForResponse(
      String threadId, String runId, BuildContext context) async {
    bool isCompleted = false;
    while (!isCompleted) {
      await Future.delayed(Duration(seconds: 2)); // Polling delay
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
        String userId = FirebaseAuth.instance.currentUser!.uid;
        CollectionReference menus = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('menus');
        menus.add({
          'menu': jsonResponse,
          'created_at': DateTime.now(),
        });
      }
    }
  }
}
