// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// class PendingRequestsScreen extends StatefulWidget {
//   @override
//   _PendingRequestsScreenState createState() => _PendingRequestsScreenState();
// }

// class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
//   final databaseReference = FirebaseDatabase.instance.ref();

//   List<PendingRequest> pendingRequests = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchPendingRequests();
//   }

 
//   // void fetchPendingRequests() {
//   //   String TO_USER_ID = '2';
//   //   String BY_USER_ID = '3';

//   //   DatabaseReference reference = FirebaseDatabase.instance.ref().child('truck_chat_users');

//   //   reference.onValue.listen((event) {
//   //     DataSnapshot snapshot = event.snapshot;
//   //     dynamic data = snapshot.value;

//   //     if (data is List) {
//   //       List<PendingRequest> pendingUsers = [];
//   //       for (var item in data) {
//   //         if (item is Map &&
//   //             item.containsKey(TO_USER_ID) &&
//   //             item[TO_USER_ID]['isChatInitiated'] == 0) {
//   //           pendingUsers.add(PendingRequest(
//   //             byUserId: BY_USER_ID,
//   //             toUserId: TO_USER_ID,
//   //           ));
//   //         }
//   //       }

//   //       setState(() {
//   //         pendingRequests.clear();
//   //         pendingRequests.addAll(pendingUsers);
//   //       });
//   //     } else {
//   //       print('Error: Firebase data is not in the expected format.');
//   //     }
//   //   }, onError: (error) {
//   //     print('Error fetching pending requests: $error');
//   //   });
//   // }


// void fetchPendingRequests() {
//     String TO_USER_ID = '2';

//     DatabaseReference reference =
//         FirebaseDatabase.instance.ref().child('truck_chat_users');

//     reference.onValue.listen((event) {
//       DataSnapshot snapshot = event.snapshot;
//       dynamic data = snapshot.value;

//       if (data is List) {
//         List<String> pendingUsers = [];
//         for (var item in data) {
//           if (item is Map &&
//               item.containsKey(TO_USER_ID) &&
//               item[TO_USER_ID]['isChatInitiated'] == 0) {
//             pendingUsers.add(item[TO_USER_ID].toString());
//           }
//         }

//         setState(() {
//           // Clear existing pending requests before updating the list
//           pendingRequests.clear();

//           // Add pending requests based on the users we found
//           pendingUsers.forEach((userId) {
//             pendingRequests.add(PendingRequest(
//               byUserId: userId,
//               toUserId: TO_USER_ID,
//             ));
//           });
//         });
//       } else {
//         print('Error: Firebase data is not in the expected format.');
//       }
//     }, onError: (error) {
//       print('Error fetching pending requests: $error');
//     });
//   }
  

  
// // void onAcceptRequest(int index) {
// //   if (index >= 0 && index < pendingRequests.length) {
// //     PendingRequest pendingRequest = pendingRequests[index];
// //     print('by user id ${pendingRequest.byUserId}');
// //     print('to user id ${pendingRequest.toUserId}');

// //     // Implement the logic to handle the acceptance of the pending request.
// //     // You can set the 'isChatInitiated' value to 1 for both users in the database.
// //   }
// // }

//   void onAcceptRequest(PendingRequest pendingRequest) {
//     print('by user id ${pendingRequest.byUserId}');
//     print('to user id ${pendingRequest.toUserId}');

//     // Implement the logic to handle the acceptance of the pending request.
//     // You can set the 'isChatInitiated' value to 1 for both users in the database.
//   }

//   void onRejectRequest(PendingRequest pendingRequest) {
//     // Implement the logic to handle the rejection of the pending request.
//     // You can remove the pending request entry from the database.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView.builder(
//         itemCount: pendingRequests.length,
//         itemBuilder: (context, index) {
//           final pendingRequest = pendingRequests[index];
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage: AssetImage('assets/user_profile.png'),
//               // You can use actual profile images here based on user data.
//             ),
//             title: Text('Superhero'), // Replace with the actual username
//             subtitle: Text(
//                 'No message yet'), // Replace with the last message if available
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => onAcceptRequest(pendingRequest),
//                   child: Text(
//                     'Accept',
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         Colors.green, // Set the background color to green
//                     foregroundColor:
//                         Colors.white, // Set the text color to white
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () => onRejectRequest(pendingRequest),
//                   child: Text('Reject'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         Colors.red, // Set the background color to green
//                     foregroundColor:
//                         Colors.white, // Set the text color to white
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class PendingRequest {
//   final String byUserId;
//   final String toUserId;

//   PendingRequest({
//     required this.byUserId,
//     required this.toUserId,
//   });
// }


// // void fetchPendingRequests() {
//   //   String TO_USER_ID = '2';

//   //   DatabaseReference reference =
//   //       FirebaseDatabase.instance.ref().child('truck_chat_users');

//   //   reference.onValue.listen((event) {
//   //     DataSnapshot snapshot = event.snapshot;
//   //     dynamic data = snapshot.value;

//   //     if (data is List) {
//   //       List<String> pendingUsers = [];
//   //       for (var item in data) {
//   //         if (item is Map &&
//   //             item.containsKey(TO_USER_ID) &&
//   //             item[TO_USER_ID]['isChatInitiated'] == 0) {
//   //           pendingUsers.add(item[TO_USER_ID].toString());
//   //         }
//   //       }

//   //       setState(() {
//   //         // Clear existing pending requests before updating the list
//   //         pendingRequests.clear();

//   //         // Add pending requests based on the users we found
//   //         pendingUsers.forEach((userId) {
//   //           pendingRequests.add(PendingRequest(
//   //             byUserId: userId,
//   //             toUserId: TO_USER_ID,
//   //           ));
//   //         });
//   //       });
//   //     } else {
//   //       print('Error: Firebase data is not in the expected format.');
//   //     }
//   //   }, onError: (error) {
//   //     print('Error fetching pending requests: $error');
//   //   });
//   // }


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PendingRequestsScreen extends StatelessWidget {
  final String currentUserId; // The ID of the current user

  PendingRequestsScreen({required this.currentUserId});

  void acceptRequest(String requestId) {
    DatabaseReference requestRef =
        FirebaseDatabase.instance.reference().child('requests/$requestId');
    requestRef.update({'status': 'accepted'});
  }

  void rejectRequest(String requestId) {
    DatabaseReference requestRef =
        FirebaseDatabase.instance.reference().child('requests/$requestId');
    requestRef.update({'status': 'rejected'});
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference requestsRef =
        FirebaseDatabase.instance.reference().child('requests');

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
      ),
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
              String senderId = requestData['senderId'];
              // You should fetch the sender's name based on the senderId from your user database

              requestWidgets.add(Card(
                child: ListTile(
                  title: Text('Sender: $senderId'), // Replace senderName with the actual sender's name
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => acceptRequest(requestId),
                        icon: Icon(Icons.check),
                        color: Colors.green,
                      ),
                      IconButton(
                        onPressed: () => rejectRequest(requestId),
                        icon: Icon(Icons.close),
                        color: Colors.red,
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


