import 'dart:convert';
import 'package:http/http.dart' as http;

class GetPreviousMessagesAsyncTask {
  final String userId;
  final double latitude;
  final double longitude;
  final int? maxPosts;
  final int? maxHours;

  List<String> server_msg_id = [];
  int status_code = 0;
  String status_message = '';

  GetPreviousMessagesAsyncTask(
    this.userId,
    this.latitude,
    this.longitude, {
    this.maxPosts,
    this.maxHours,
  });

  void onGetPreviousMessagesResult(
    bool success,
    int status_code,
    String status_message,
    List<String> server_msg_id,
  ) {
    if (success) {
      // Process the fetched messages
      print("Messages: $server_msg_id");
      print("Status Code: $status_code");
      print("Status Message: $status_message");
    } else {
      // Handle the error
      print("Error: $status_message");
    }
    // Implement your logic here after getting previous messages
  }

  Future<void> runNow() async {
    Uri url =
        Uri.parse("http://smarttruckroute.com/bb/v1/get_previous_messages");
    Map<String, dynamic> requestBody = {
      "user_id": userId,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      // Add other optional parameters if needed
      "max_posts": maxPosts,
      "max_hours": maxHours,
    };

    try {
      http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("response body");
        print(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        status_code = jsonResponse['status'];
        if (jsonResponse.containsKey('message')) {
          status_message = jsonResponse['message'];
        } else {
          status_message = '';
        }

        List<dynamic> serverMsgIds = jsonResponse['server_msg_id'];
        server_msg_id =
            List<String>.from(serverMsgIds.map((e) => e.toString()));

        onGetPreviousMessagesResult(
            true, status_code, status_message, server_msg_id);
      } else {
        status_message = 'Connection Error';
        onGetPreviousMessagesResult(
            false, status_code, status_message, server_msg_id);
      }
    } catch (e) {
      status_message = e.toString();
      onGetPreviousMessagesResult(
          false, status_code, status_message, server_msg_id);
    }
  }

  Future<bool> doInBackground() async {
    await runNow();
    return true;
  }

  Future<void> execute() async {
    await doInBackground();
  }
}
