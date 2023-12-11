import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/create_thread_service.dart';
import '../service/add_user_message_service.dart';
import '../service/run_thread_service_json.dart';
import '../service/check_run_status_service.dart';
import '../service/get_messages_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveButton extends StatefulWidget {
  final String menuMessage;

  SaveButton({Key? key, required this.menuMessage}) : super(key: key);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return isSaving
      ? const CircularProgressIndicator()
      : ElevatedButton(
        onPressed: () async {
          setState(() {
            isSaving = true; // Start saving
          });
         
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('The AI assistant is generating your weekly menu...'),
          backgroundColor: Colors.green,
        ),
      );
          final dialogContext = Navigator.of(context, rootNavigator: true).context;
          String menuName = await showDialog(
          context: dialogContext,
          builder: (dialogContext) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter a name for the menu:'), // Instruction for the user.
                TextField(
                  onSubmitted: (value) => Navigator.pop(dialogContext, value),
                ),
              ],
            ),
          ),
        );
        _handleSave(context, menuName);
      },
      child: const Text('Save Menu'),
    );
  }

  void _handleSave(BuildContext context, String menuName) async {
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

      await _waitForResponse(threadId, runId, context, menuName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isSaving = false; // Finish saving
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Menu has been succesfully saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _waitForResponse(
      String threadId, String runId, BuildContext context, String menuName) async {
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

        print('Menu Name: $menuName');
        
        menus.add({
          'menu': jsonResponse,
          'created_at': DateTime.now(),
          'name': menuName,
        });
      }
    }
  }
}
