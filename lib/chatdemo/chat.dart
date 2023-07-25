import 'dart:convert';
import 'dart:io';
import 'package:chat/utils/alert_dialog.dart';
import 'package:chat/utils/avatar.dart';
import 'package:chat/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';
import 'package:chat/utils/shared_pref.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String chatIds;
  final String chatIdr;
  final String imagePath;
  final String userName;

  ChatScreen(
      {required this.chatIds,
      required this.chatIdr,
      required this.imagePath,
      required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? currentUserHandle;
  String? currentUserEmojiId;
  late DatabaseReference _chatRefs;
  late DatabaseReference _chatRefr;

  late String
      currentUserId; // Assuming you have a way to get the current user ID.

  String emojiId = '';
  String userName = '';
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatRefs =
        FirebaseDatabase.instance.ref().child('chats').child(widget.chatIds);

    _chatRefr =
        FirebaseDatabase.instance.ref().child('chats').child(widget.chatIdr);

    currentUserId = "3"; // Replace with your logic to get the current user ID.

    currentUserHandle =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

    currentUserEmojiId =
        SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatRefs.push().set({
        'senderId': currentUserId,
        'receiverId': '1',
        'senderEmojiId': currentUserEmojiId,
        'senderUserName': currentUserHandle,
        // 'receiverEmojiId': emojiId,
        // 'receiverUserName': userName,
        'message': message,
        'timestamp': ServerValue.timestamp,
      });

      _chatRefr.push().set({
        'senderId': currentUserId,
        'receiverId': '1',
        'senderEmojiId': currentUserEmojiId,
        'senderUserName': currentUserHandle,
        // 'receiverEmojiId': emojiId,
        // 'receiverUserName': userName,
        'message': message,
        'timestamp': ServerValue.timestamp,
      });
      // final receiverFCMToken = await getFCMToken('2');
      // // Send notification to the receiver
      // await sendNotificationToReceiver(
      //     receiverFCMToken ?? '', currentUserId, '2', message);
      _messageController.clear();
    }
  }

  Future<void> _sendImage() async {
    sendImageDialog(context, () => _openCamera(), () => _openGallery());
  }

  Future<void> _openCamera() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile = await _picker.pickImage(
      source: ImageSource
          .camera, // Change this to ImageSource.camera for camera access
    );

    if (pickedFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        _chatRefs.push().set({
          'senderId': currentUserId,
          'receiverId': '1',
          'senderEmojiId': currentUserEmojiId,
          'senderUserName': currentUserHandle,
          'receiverEmojiId': emojiId,
          'receiverUserName': userName,
          'message': imageUrl,
          'timestamp': ServerValue.timestamp,
        });
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedFile = await _picker.pickImage(
      source: ImageSource
          .gallery, // Change this to ImageSource.camera for camera access
    );

    if (pickedFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        _chatRefs.push().set({
          'senderId': currentUserId,
          'receiverId': '1',
          'senderEmojiId': currentUserEmojiId,
          'senderUserName': currentUserHandle,
          'receiverEmojiId': emojiId,
          'receiverUserName': userName,
          'message': imageUrl,
          'timestamp': ServerValue.timestamp,
        });
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

//   Future<String?> _getAndStoreFCMToken(String receiverId) async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;
//     String? token = await messaging.getToken();

//     if (token != null) {
//       // Store the FCM token in the database
//       DatabaseReference fcmTokenRef = FirebaseDatabase.instance
//           .ref()
//           .child('users')
//           .child(receiverId)
//           .child('fcmToken');
//       fcmTokenRef.set(token);
//     }
//         return token;

//   }

// Future<bool> checkFcmTokenExistence(String receiverId) async {
//   DatabaseReference fcmTokenRef = FirebaseDatabase.instance
//       .ref()
//       .child('users')
//       .child(receiverId)
//       .child('fcmToken');

//   try {
//     // Use the snapshot property of DatabaseEvent to get the DataSnapshot
//     DatabaseEvent event = await fcmTokenRef.once();
//     DataSnapshot dataSnapshot = event.snapshot;

//     // Check if the token exists
//     return dataSnapshot.value != null;
//   } catch (error) {
//     print('Error: $error');
//     return false;
//   }
// }

  Future<String?> getFCMToken(String receiverId) async {
    DatabaseReference fcmTokenRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(receiverId)
        .child('fcmToken');

    // Check if the token already exists in the database
    DatabaseEvent event = await fcmTokenRef.once();
    DataSnapshot dataSnapshot = event.snapshot;

    String? token = dataSnapshot.value as String?;

    if (token == null) {
      // If the token doesn't exist in the database, generate a new token
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      token = await messaging.getToken();

      if (token != null) {
        // Store the newly generated token in the database
        fcmTokenRef.set(token);
      }
    }

    return token;
  }

  Future<void> sendNotificationToReceiver(String receiverFCMToken,
      String senderId, String receiverId, String message) async {
    print('receiver token $receiverFCMToken');
    // Replace 'YOUR_SERVER_KEY' with your FCM server key
    String serverKey =
        'AAAATh7WnDw:APA91bHh8z9AjM5rA-JVvE3vGYt1Opc5DteMM4nuAqAAfKsZzbSTWZNkcfaJwebVcoFb56OhCOA7yhod8u2iKoimrVYgBZMCyPBFiBhr3GdY_S_EAb6euz-l55N4hbPKH2TopZZ9ZOT3';
    String url = 'https://fcm.googleapis.com/fcm/send';

    // Replace 'YOUR_NOTIFICATION_TITLE' and 'YOUR_NOTIFICATION_BODY' with your desired notification title and body
    String notificationTitle = 'New Message $message';
    String notificationBody = 'You have received a new message from $senderId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': notificationBody,
            'title': notificationTitle,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'senderUserId': senderId,
            'receiverUserId': receiverId,
          },
          'to': receiverFCMToken,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print(
            'Failed to send notification. StatusCode: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send notification. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevent the default back button
        leadingWidth: kToolbarHeight + 32.0, // Adjust this value as needed
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Handle back button press here
                Navigator.of(context).pop();
              },
            ),
            // SizedBox(width: 8), // Adjust this value for spacing between arrow and image
            SizedBox(
              width:
                  40, // Set the width of the image container equal to the height for a square image
              height: kToolbarHeight,
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.contain, // Maintain the image's aspect ratio
              ),
            ),
          ],
        ),
        title: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(width: 8), // Adjust this value for spacing between image and title
              Text(widget.userName),
            ],
          ),
        ),
        centerTitle: false, // Make sure centerTitle is set to false
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatRefs.orderByChild('timestamp').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  Map<dynamic, dynamic>? data = (snapshot.data as DatabaseEvent)
                      .snapshot
                      .value as Map<dynamic, dynamic>?;

                  if (data != null) {
                    List<String> messageKeys =
                        data.keys.cast<String>().toList();

// Sort the messageKeys based on timestamp
                    messageKeys.sort((a, b) {
                      int timestampA = data[a]['timestamp'] ?? 0;
                      int timestampB = data[b]['timestamp'] ?? 0;
                      return timestampA.compareTo(timestampB);
                    });
// Reverse the sorted messageKeys list to display latest messages at the bottom
                    messageKeys = messageKeys.reversed.toList();

// Now the messageKeys list contains keys in the correct chronological order




                    return ListView.builder(
                      // reverse: true,
                      itemCount: messageKeys.length,
                      itemBuilder: (context, index) {
                        String messageKey = messageKeys[index];
                        Map<dynamic, dynamic> messageData = data[messageKey];

                        // emojiId = messageData['receiverEmojiId'];
                        // userName = messageData['receiverUserName'];
                        //testing

                        emojiId = messageData['senderEmojiId'];
                        userName = messageData['senderUserName'];

                        // Check if the 'message' field is available and not empty
                        String message = messageData['message'] ?? '';
                        String imageUrl =
                            message.startsWith('https') ? message : '';

                        if (message.isNotEmpty) {
                          String senderId = messageData['senderId'];

                          // Check if the message contains an image URL, if yes, then it's an image message
                          bool isImageMessage = imageUrl.isNotEmpty;

                          //  String message = messageData['message'] ?? '';
                          bool isCurrentUser = senderId == currentUserId;
                          return MessageBubble(
                            message: message,
                            isCurrentUser: isCurrentUser,
                            isImageMessage: isImageMessage,
                            imageUrl: imageUrl,
                          );
                        } else {
                          // If the message is empty, return an empty container to avoid displaying the bubble
                          return Container();
                        }
                      },
                      reverse: true, // Keep latest messages at the bottom
                    );
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),




          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(
                    width:
                        8), // Add some space between the text field and the send button
                IconButton(
                  onPressed:
                      _sendImage, // Call the function to open the gallery
                  icon: Icon(
                    Icons.image,
                    color: Colors.blue[300],
                  ), // You can use any other icon here
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final bool
      isImageMessage; // Add a new boolean variable to identify image messages
  final String imageUrl; // Add a new variable to store the image URL

  MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.isImageMessage,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          // Open the full image when tapped
          if (isImageMessage) {
            _showFullImage(context, imageUrl);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue[400] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: isImageMessage
              ? Image.network(
                  imageUrl,
                  width:
                      200, // Set the width of the image as per your requirement
                  height:
                      200, // Set the height of the image as per your requirement
                  fit: BoxFit.cover, // Adjust the image fit as needed
                )
              : Text(
                  message,
                  style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black),
                ),
        ),
      ),
    );
  }
}

void _showFullImage(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          ),
        ),
      ),
    ),
  );
}
