// import 'package:chat/utils/avatar.dart';
// import 'package:chat/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:intl/intl.dart';
// import 'package:chat/utils/shared_pref.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatId;
//   final String imagePath;
//   final String userName;

//   ChatScreen(
//       {required this.chatId, required this.imagePath, required this.userName});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   String? currentUserHandle;
//   String? currentUserEmojiId;
//   late DatabaseReference _chatRef;
//   late String
//       currentUserId; // Assuming you have a way to get the current user ID.

//   String emojiId = '';
//   String userName = '';
//   TextEditingController _messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _chatRef =
//         FirebaseDatabase.instance.ref().child('chats').child(widget.chatId);
//     currentUserId = "2"; // Replace with your logic to get the current user ID.

//     currentUserHandle =
//         SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

//     currentUserEmojiId =
//         SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();
//   }

//   void _sendMessage() {
//     String message = _messageController.text.trim();
//     if (message.isNotEmpty) {

//       _chatRef.push().set({
//         'senderId': currentUserId,
//         'receiverId': '1',
//         'senderEmojiId': currentUserEmojiId,
//         'senderUserName': currentUserHandle,
//         'receiverEmojiId': emojiId,
//         'receiverUserName': userName,
//         'message': message,
//         'timestamp': ServerValue.timestamp,
//       });
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // Prevent the default back button
//         leadingWidth: kToolbarHeight + 32.0, // Adjust this value as needed
//         leading: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.arrow_back),
//               onPressed: () {
//                 // Handle back button press here
//                 Navigator.of(context).pop();
//               },
//             ),
//             // SizedBox(width: 8), // Adjust this value for spacing between arrow and image
//             SizedBox(
//               width:
//                   40, // Set the width of the image container equal to the height for a square image
//               height: kToolbarHeight,
//               child: Image.asset(
//                 widget.imagePath,
//                 fit: BoxFit.contain, // Maintain the image's aspect ratio
//               ),
//             ),
//           ],
//         ),
//         title: Container(
//           alignment: Alignment.centerLeft,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               // SizedBox(width: 8), // Adjust this value for spacing between image and title
//               Text(widget.userName),
//             ],
//           ),
//         ),
//         centerTitle: false, // Make sure centerTitle is set to false
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _chatRef.orderByChild('timestamp').onValue,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData && snapshot.data != null) {
//                   Map<dynamic, dynamic>? data = (snapshot.data as DatabaseEvent)
//                       .snapshot
//                       .value as Map<dynamic, dynamic>?;

//                   if (data != null) {
//                     List<String> messageKeys =
//                         data.keys.cast<String>().toList();

// // Sort the messageKeys based on timestamp
//                     messageKeys.sort((a, b) {
//                       int timestampA = data[a]['timestamp'] ?? 0;
//                       int timestampB = data[b]['timestamp'] ?? 0;
//                       return timestampA.compareTo(timestampB);
//                     });
// // Reverse the sorted messageKeys list to display latest messages at the bottom
//                     messageKeys = messageKeys.reversed.toList();

// // Now the messageKeys list contains keys in the correct chronological order

//                     return ListView.builder(
//                       //  reverse: true,
//                       itemCount: messageKeys.length,
//                       itemBuilder: (context, index) {
//                         String messageKey = messageKeys[index];
//                         Map<dynamic, dynamic> messageData = data[messageKey];

//                         emojiId = messageData['receiverEmojiId'];
//                         userName = messageData['receiverUserName'];

//                         // Check if the 'message' field is available and not empty
//                         String message = messageData['message'] ?? '';
//                         if (message.isNotEmpty) {
//                           String senderId = messageData['senderId'];

//                           //  String message = messageData['message'] ?? '';
//                           bool isCurrentUser = senderId == currentUserId;
//                           return MessageBubble(
//                             message: message,
//                             isCurrentUser: isCurrentUser,
//                           );
//                         } else {
//                           // If the message is empty, return an empty container to avoid displaying the bubble
//                           return Container();
//                         }
//                       },
//                       reverse: true, // Keep latest messages at the bottom
//                     );
//                   }
//                 }
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                     width:
//                         8), // Add some space between the text field and the send button
//                 GestureDetector(
//                   onTap: _sendMessage,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Icon(
//                         Icons.send,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final String message;
//   final bool isCurrentUser;

//   MessageBubble({required this.message, required this.isCurrentUser});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         decoration: BoxDecoration(
//           color: isCurrentUser ? Colors.blue : Colors.grey,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           message,
//           style: TextStyle(color: isCurrentUser ? Colors.white : Colors.white),
//         ),
//       ),
//     );
//   }
// }

//testing 1 for send images
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

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String imagePath;
  final String userName;

  ChatScreen(
      {required this.chatId, required this.imagePath, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? currentUserHandle;
  String? currentUserEmojiId;
  late DatabaseReference _chatRef;
  late String
      currentUserId; // Assuming you have a way to get the current user ID.

  String emojiId = '';
  String userName = '';
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatRef =
        FirebaseDatabase.instance.ref().child('chats').child(widget.chatId);
    currentUserId = "2"; // Replace with your logic to get the current user ID.

    currentUserHandle =
        SharedPrefs.getString(SharedPrefsKeys.CURRENT_USER_CHAT_HANDLE);

    currentUserEmojiId =
        SharedPrefs.getInt(SharedPrefsKeys.CURRENT_USER_AVATAR_ID).toString();
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatRef.push().set({
        'senderId': currentUserId,
        'receiverId': '1',
        'senderEmojiId': currentUserEmojiId,
        'senderUserName': currentUserHandle,
        'receiverEmojiId': emojiId,
        'receiverUserName': userName,
        'message': message,
        'timestamp': ServerValue.timestamp,
      });
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

        _chatRef.push().set({
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

        _chatRef.push().set({
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
              stream: _chatRef.orderByChild('timestamp').onValue,
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

                    // return ListView.builder(
                    //   //  reverse: true,
                    //   itemCount: messageKeys.length,
                    //   itemBuilder: (context, index) {
                    //     String messageKey = messageKeys[index];
                    //     Map<dynamic, dynamic> messageData = data[messageKey];

                    //     emojiId = messageData['receiverEmojiId'];
                    //     userName = messageData['receiverUserName'];

                    //     // Check if the 'message' field is available and not empty
                    //     String message = messageData['message'] ?? '';
                    //     if (message.isNotEmpty) {
                    //       String senderId = messageData['senderId'];

                    //       //  String message = messageData['message'] ?? '';
                    //       bool isCurrentUser = senderId == currentUserId;
                    //       return MessageBubble(
                    //         message: message,
                    //         isCurrentUser: isCurrentUser,
                    //       );
                    //     } else {
                    //       // If the message is empty, return an empty container to avoid displaying the bubble
                    //       return Container();
                    //     }
                    //   },
                    //   reverse: true, // Keep latest messages at the bottom
                    // );
                    return ListView.builder(
                      // reverse: true,
                      itemCount: messageKeys.length,
                      itemBuilder: (context, index) {
                        String messageKey = messageKeys[index];
                        Map<dynamic, dynamic> messageData = data[messageKey];

                        emojiId = messageData['receiverEmojiId'];
                        userName = messageData['receiverUserName'];

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
                  icon: Icon(Icons.image), // You can use any other icon here
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

// class MessageBubble extends StatelessWidget {
//   final String message;
//   final bool isCurrentUser;

//   MessageBubble({required this.message, required this.isCurrentUser});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         decoration: BoxDecoration(
//           color: isCurrentUser ? Colors.blue : Colors.grey,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Text(
//           message,
//           style: TextStyle(color: isCurrentUser ? Colors.white : Colors.white),
//         ),
//       ),
//     );
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final String message;
//   final bool isCurrentUser;

//   MessageBubble({required this.message, required this.isCurrentUser});

//   @override
//   Widget build(BuildContext context) {
//     if (message.startsWith('http')) {
//       // If the message is an image URL, display the image
//       return Align(
//         alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: Image.network(
//           message,
//           height: 200, // Adjust the height as needed
//           width: 200, // Adjust the width as needed
//         ),
//       );
//     } else {
//       // If the message is a regular text message, display the text bubble
//       return Align(
//         alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           decoration: BoxDecoration(
//             color: isCurrentUser ? Colors.blue : Colors.grey,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Text(
//             message,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }
//   }
// }

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
            color: isCurrentUser ? Colors.blue : Colors.grey,
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
                      color: isCurrentUser ? Colors.white : Colors.white),
                ),
        ),
      ),
    );
  }
}

// void _showFullImage(BuildContext context, String imageUrl) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       content: Image.network(imageUrl, fit: BoxFit.contain,),
//     ),
//   );
// }
// void _showFullImage(BuildContext context, String imageUrl) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         child: GestureDetector(
//           onTap: () {
//             Navigator.pop(context); // Close the dialog when tapped
//           },
//           child: Container(
//             width: MediaQuery.of(context).size.width, // Full screen width
//             height: MediaQuery.of(context).size.height, // Full screen height
//             child: Image.network(
//               imageUrl,
//               fit: BoxFit.contain,
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

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


