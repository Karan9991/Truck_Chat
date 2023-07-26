import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/constants.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

  void acceptRequest(String requestId) {
    currentUserHandle =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

    currentUserEmojiId =
        SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();

    String chatIds = senderId + receiverId;
    String chatIdr = receiverId + senderId;

    DatabaseReference requestRef =
        FirebaseDatabase.instance.ref().child('requests/$requestId');

    requestRef.update({'status': 'accepted'});

    _initializeChat(senderId, receiverId);

    // DatabaseReference chatRefs =
    //     FirebaseDatabase.instance.ref().child('chats').child(chatIds);

    // DatabaseReference chatRefr =
    //     FirebaseDatabase.instance.ref().child('chats').child(chatIdr);

    // print('senderusername $currentUserHandle');
    // print('senderemojiid $currentUserEmojiId');

    // chatRefs.push().set({
    //   'senderId': senderId,
    //   'receiverId': receiverId,
    //   'senderEmojiId': currentUserEmojiId,
    //   'senderUserName': currentUserHandle,
    //   // 'receiverEmojiId': emojiId,
    //   // 'receiverUserName': userName,
    //   'message': '',
    //   'timestamp': 0,
    // });

    // chatRefr.push().set({
    //   'senderId': senderId,
    //   'receiverId': receiverId,
    //   // 'senderEmojiId': currentUserEmojiId,
    //   // 'senderUserName': currentUserHandle,     to be continue here
    //   'senderEmojiId': emojiId,
    //   'senderUserName': userName,
    //   'message': '',
    //   'timestamp': 0,
    // });
  }

  void rejectRequest(String requestId) {
    DatabaseReference requestRef =
        FirebaseDatabase.instance.ref().child('requests/$requestId');
    requestRef.update({'status': 'rejected'});
  }

  void _initializeChat(String userId, String receiverId) {
    var timestamp = DateTime.now().millisecondsSinceEpoch;

    // Send the message to the receiver
    // _databaseReference
    //     .child('messages')
    //     .child(userId)
    //     .child(receiverId)
    //     .push()
    //     .set({
    //   'senderId': userId,
    //   'receiverId': receiverId,
    //   'message': '',
    //   'timestamp': timestamp,
    // });

    // _databaseReference
    //     .child('messages')
    //     .child(receiverId)
    //     .child(userId)
    //     .push()
    //     .set({
    //   'senderId': userId,
    //   'receiverId': receiverId,
    //   'message': '',
    //   'timestamp': timestamp,
    // });

    // Update the chat list for the sender (widget.userId)
    _updateChatList(userId, receiverId, '', timestamp, emojiId, userName);

    // Update the chat list for the receiver (widget.receiverId)
    _updateChatList(
        receiverId, userId, '', timestamp, receiverEmojiId, receiverUserName);
  }

  void _updateChatList(String userId, String otherUserId, String lastMessage,
      int timestamp, String emojiId, String userName) async {
    try {
      DataSnapshot snapshot = await _databaseReference
          .child('chatList')
          .child(userId)
          .child(otherUserId)
          .get();
      if (snapshot.value != null) {
        // Chat already exists, update last message and timestamp
        await _databaseReference
            .child('chatList')
            .child(userId)
            .child(otherUserId)
            .update({
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'newMessages':
              false, // Set newMessages to true to indicate there are new messages
        });
      } else {
        // Chat does not exist, create a new chat list entry
        DataSnapshot userSnapshot =
            await _databaseReference.child('users').child(otherUserId).get();
        Map<dynamic, dynamic>? userData =
            userSnapshot.value as Map<dynamic, dynamic>?;
        String otherUserName = userData?['userName'] ?? 'Unknown User';
        String otherUserImage = userData?['userImage'] ?? 'default_image_url';

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
      }
    } catch (error) {
      print('Error updating chat list: $error');
    }
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
                        onPressed: () => acceptRequest(requestId),
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
