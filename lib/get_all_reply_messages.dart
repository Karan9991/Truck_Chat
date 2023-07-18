//original

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<bool> runNow() async {
//   int status_code = 0;
//   int counts = 0;
//   int conversation_timestamp = 0;

//   String status_message = '';
//   String conversation_topic = '';
//   List<ReplyMsg> reply_msgs = [];

//   final url =
//       Uri.parse("http://smarttruckroute.com/bb/v1/get_all_reply_message");

//   Map<String, dynamic> requestBody = {
//     "server_message_id": 48702,
//   };

//   try {
//     http.Response response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(requestBody),
//     );
//     if (response.statusCode == 200) {
//       final result = response.body;

//       try {
//         final jsonResult = jsonDecode(result);
//         // status_code = jsonResult[PARAM_STATUS];

//         if (jsonResult.containsKey('message')) {
//           status_message = jsonResult['message'];
//         } else {
//           status_message = '';
//         }

//         counts = jsonResult['counts'];

//         conversation_topic = jsonResult['original'];
//         print("conversation topic $conversation_topic");
//         try {
//           conversation_timestamp = int.tryParse(jsonResult['timestamp']) ?? 0;
//         } catch (e) {
//           conversation_timestamp = 0;
//         }

//         final jsonReplyList = jsonResult['messsage_reply_list'];
//         if (counts == jsonReplyList.length) {
//           for (var i = 0; i < counts; ++i) {
//             final jsonReply = jsonReplyList[i];
//             final rid = jsonReply['server_msg_reply_id'];
//             final replyMsg = jsonReply['reply_msg'];
//             final uid = jsonReply['user_id'];
//             final emojiId = jsonReply['emoji_id'];
//             int timestamp;
//             try {
//               timestamp = int.tryParse(jsonReply['timestamp']) ?? 0;
//             } catch (e) {
//               timestamp = 0;
//             }

//             reply_msgs.add(ReplyMsg(rid, uid, replyMsg, timestamp, emojiId));
//           }
//         }

//         return true;
//       } catch (e) {
//         print(e);
//         status_message = e.toString();
//       }
//     } else {
//       status_message = 'Connection Error';
//     }
//   } catch (e) {
//     print(e);
//   }

//   return false;
// }

// class ReplyMsg {
//   final String rid;
//   final String uid;
//   final String replyMsg;
//   final int timestamp;
//   final String emojiId;

//   ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId);
// }

//testing

// class ReplyMsg {
//   final int rid;
//   final int uid;
//   final String replyMsg;
//   final int timestamp;
//   final String emojiId;
//     final String topic;

//   ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId, this.topic);

// }

class ReplyMsg {
  final int rid;
  final int uid;
  final String replyMsg;
  final int timestamp;
  final String emojiId;
  final String topic;
  final String driverName;
  final String privateChat;

  ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId,
      this.topic, this.driverName, this.privateChat);
}
// class ReplyMsg {
//   final int rid;
//   final int uid;
//   final String replyMsg;
//   final int timestamp;
//   final String emojiId;
//     final String topic;
//     final String driverName;

//   ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId, this.topic, this.driverName);

// }

// class ReplyMsgr {
//   final int rid;
//   final int uid;
//   final String replyMsg;
//   final int timestamp;
//   final String emojiId;
//   final String topic;

//   ReplyMsgr(
//       {required this.rid,
//       required this.uid,
//       required this.replyMsg,
//       required this.timestamp,
//       required this.emojiId,
//       required this.topic});

//   factory ReplyMsgr.fromJson(Map<String, dynamic> json) {
//     return ReplyMsgr(
//       rid: json['rid'],
//       uid: json['uid'],
//       replyMsg: json['replyMsg'],
//       timestamp: json['timestamp'],
//       emojiId: json['emojiId'],
//       topic: json['topic'],
//     );
//   }
// }

class ReplyMsgg {
  final String rid;
  final int uid;
  final String replyMsg;
  final int timestamp;
  // final String emojiId;

  // ReplyMsg(this.rid, this.uid, this.replyMsg, this.timestamp, this.emojiId);
  ReplyMsgg(this.rid, this.uid, this.replyMsg, this.timestamp);
}
