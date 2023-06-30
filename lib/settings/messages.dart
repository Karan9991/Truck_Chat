import 'package:flutter/material.dart';
import '/utils/avatar.dart';

class MessagesScreen extends StatelessWidget {
  final TextEditingController _chatHandleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: ListView(
        children: [
          _buildListTile(
            'Chat Handle',
            'Prepend your messages with',
            () => _showChatHandleDialog(context),
          ),
          _buildListTile(
            'Choose Avatar',
            'Avatar',
            () {
              showAvatarSelectionDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, String description, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
         style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          
          color: Colors.grey, // Replace with your desired text color
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showChatHandleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chat Handle'),
          content: TextField(
            controller: _chatHandleController,
            decoration: InputDecoration(hintText: 'Enter chat handle'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String chatHandle = _chatHandleController.text;
                print('Chat Handle: $chatHandle');
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
