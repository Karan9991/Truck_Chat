// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// class SendRequestScreen extends StatelessWidget {
//   final String senderId; // The current user's ID
//   final String receiverId; // The ID of the user to whom the request is sent

//   SendRequestScreen({required this.senderId, required this.receiverId});

//   void sendRequest() {
//     DatabaseReference requestsRef =
//         FirebaseDatabase.instance.reference().child('requests');

//     Request request = Request(
//       senderId: senderId,
//       receiverId: receiverId,
//       status: 'pending',
//     );

//     requestsRef.push().set(request.toJson());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Send Request'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: sendRequest,
//           child: Text('Send Request'),
//         ),
//       ),
//     );
//   }
// }




// class Request {
//   final String senderId;
//   final String receiverId;
//   final String status;

//   Request({
//     required this.senderId,
//     required this.receiverId,
//     required this.status,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'status': status,
//     };
//   }
// }
