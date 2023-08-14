import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chat/utils/alert_dialog.dart';

class PendingRequestsScreen extends StatelessWidget {
  final String currentUserId; // The ID of the current user

  String emojiId = '';
  String userName = '';
  String receiverEmojiId = '';
  String receiverUserName = '';
  String senderId = '';
  String receiverId = '';
  String? currentUserHandle;
  String? currentUserEmojiId;
  DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  PendingRequestsScreen({required this.currentUserId});

  void acceptRequest(String requestId, BuildContext context) {
    String? chatHandle =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);
    int? avatarId = SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID);
    if (chatHandle == null) {
      showChatHandleDialog(context);
    } else if (avatarId == null) {
      showAvatarSelectionDialog(context);
    } else {
      currentUserHandle =
          SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

      currentUserEmojiId =
          SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();

      DatabaseReference requestRef =
          FirebaseDatabase.instance.ref().child('requests/$requestId');

      requestRef.update({'status': 'accepted'}).then((_) async {
        DatabaseEvent event = await requestRef.once();
        DataSnapshot snapshot = event.snapshot;

        var requestData = snapshot.value as Map<dynamic, dynamic>;
        if (requestData != null) {
          senderId = requestData['senderId'];
          receiverId = requestData['receiverId'];
          emojiId = requestData['senderEmojiId'];
          userName = requestData['senderUserName'];
          receiverEmojiId = requestData['receiverEmojiId'];
          receiverUserName = requestData['receiverUserName'];

          await _initializeChat(senderId, receiverId);
          await requestRef.remove();
        }
      });
    }
  }

  Future<void> _initializeChat(String userId, String receiverId) async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    // Update the chat list for the sender (widget.userId)
    await _updateChatList(userId, receiverId, '', timestamp, emojiId, userName);

    // Update the chat list for the receiver (widget.receiverId)
    await _updateChatList(
        receiverId, userId, '', timestamp, receiverEmojiId, receiverUserName);
  }

  Future<void> _updateChatList(
      String userId,
      String otherUserId,
      String lastMessage,
      int timestamp,
      String emojiId,
      String userName) async {
    try {
      await _databaseReference
          .child('chatList')
          .child(userId)
          .child(otherUserId)
          .set({
        'userName': userName,
        'emojiId': emojiId,
        'receiverId': otherUserId,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
        'newMessages': false,
      });
    } catch (error) {
      print('Error updating chat list: $error');
    }
  }

  // void rejectRequest(String requestId) {
  //   DatabaseReference requestRef =
  //       FirebaseDatabase.instance.ref().child('requests/$requestId');
  //   requestRef.update({'status': 'rejected'});
  // }
  void rejectRequest(String requestId) {
    DatabaseReference requestRef =
        FirebaseDatabase.instance.ref().child('requests/$requestId');
    requestRef.remove(); // Remove the entire request node from the database
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference requestsRef =
        FirebaseDatabase.instance.ref().child('requests');

    return Scaffold(
      body: StreamBuilder(
        stream: requestsRef
            .orderByChild('receiverId')
            .equalTo(currentUserId)
            .onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text('No pending requests.'),
            );
          }

          Map<dynamic, dynamic> requestsData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<Widget> requestWidgets = [];

          requestsData.forEach((requestId, requestData) {
            if (requestData['status'] == 'pending') {
              senderId = requestData['senderId'];
              receiverId = requestData['receiverId'];
              emojiId = requestData['senderEmojiId'];
              userName = requestData['senderUserName'];
              receiverEmojiId = requestData['receiverEmojiId'];
              receiverUserName = requestData['receiverUserName'];
              // Find the corresponding Avatar for the emoji_id
              Avatar? matchingAvatar = avatars.firstWhere(
                (avatar) => avatar.id == int.parse(receiverEmojiId),
                orElse: () => Avatar(id: 0, imagePath: ''),
              );

              requestWidgets.add(Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(matchingAvatar.imagePath),
                  ),
                  title: Text(
                      receiverUserName), // Replace senderName with the actual sender's name
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => acceptRequest(requestId, context),
                        child: Text(
                          'Accept',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Set the background color to green
                          foregroundColor:
                              Colors.white, // Set the text color to white
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => rejectRequest(requestId),
                        child: Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Set the background color to green
                          foregroundColor:
                              Colors.white, // Set the text color to white
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            }
          });

          if (requestWidgets.isEmpty) {
            return Center(
              child: Text('No pending requests.'),
            );
          }

          return ListView(
            children: requestWidgets,
          );
        },
      ),
    );
  }
}
