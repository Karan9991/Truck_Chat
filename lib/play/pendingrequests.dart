// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// class PendingRequestsScreen extends StatelessWidget {
//   final String currentUserId; // The ID of the current user

//   PendingRequestsScreen({required this.currentUserId});

//   void acceptRequest(String requestId) {
//     DatabaseReference requestRef =
//         FirebaseDatabase.instance.reference().child('requests/$requestId');
//     requestRef.update({'status': 'accepted'});
//   }

//   void rejectRequest(String requestId) {
//     DatabaseReference requestRef =
//         FirebaseDatabase.instance.reference().child('requests/$requestId');
//     requestRef.update({'status': 'rejected'});
//   }

//   @override
//   Widget build(BuildContext context) {
//     DatabaseReference requestsRef =
//         FirebaseDatabase.instance.reference().child('requests');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pending Requests'),
//       ),
//       body: StreamBuilder(
//         stream: requestsRef
//             .orderByChild('receiverId')
//             .equalTo(currentUserId)
//             .onValue,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData ||
//               snapshot.data == null ||
//               snapshot.data!.snapshot.value == null) {
//             return Center(
//               child: Text('No pending requests.'),
//             );
//           }

//     Map<dynamic, dynamic> requestsData =
//         snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

//           List<Widget> requestWidgets = [];

//           requestsData.forEach((requestId, requestData) {
//             if (requestData['status'] == 'pending') {
//               String senderId = requestData['senderId'];
//               // You should fetch the sender's name based on the senderId from your user database

//               requestWidgets.add(Card(
//                 child: ListTile(
//                   title: Text('Sender: $senderId'), // Replace senderName with the actual sender's name
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         onPressed: () => acceptRequest(requestId),
//                         icon: Icon(Icons.check),
//                         color: Colors.green,
//                       ),
//                       IconButton(
//                         onPressed: () => rejectRequest(requestId),
//                         icon: Icon(Icons.close),
//                         color: Colors.red,
//                       ),
//                     ],
//                   ),
//                 ),
//               ));
//             }
//           });

//           if (requestWidgets.isEmpty) {
//             return Center(
//               child: Text('No pending requests.'),
//             );
//           }

//           return ListView(
//             children: requestWidgets,
//           );
//         },
//       ),
//     );
//   }
// }
