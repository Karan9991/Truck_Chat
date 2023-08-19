
import 'package:chat/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Conversation {
  final String conversationId;
  final String topic;
  final int timestamp;
  String replyCount;
  bool isRead;
  bool isDeleted; // Add this property

  Conversation({
    required this.conversationId,
    required this.topic,
    required this.timestamp,
    required this.replyCount,
    required this.isRead,
    this.isDeleted = false, // Initialize it to false
  });
}

Future<List<Conversation>> getStoredConversations() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> encodedConversations =
      prefs.getStringList(SharedPrefsKeys.CONVERSATIONS) ?? [];

  List<Conversation> conversations =
      encodedConversations.map((encodedConversation) {
    Map<String, dynamic> conversationMap = json.decode(encodedConversation);
    return Conversation(
      conversationId: conversationMap[Constants.CONVERSATION_ID],
            topic: conversationMap['topic'],
      timestamp: conversationMap['timestamp'],

      replyCount: conversationMap[Constants.REPLY_COUNT],
      isRead: conversationMap[Constants.IS_READ],
            isDeleted: conversationMap['isDeleted'],

    );
  }).toList();

  return conversations;
}


Future<void> storeConversations(List<Conversation> conversations) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  

  List<String> encodedConversations = conversations.map((conversation) {
    Map<String, dynamic> conversationMap = {
      Constants.CONVERSATION_ID: conversation.conversationId,
            'topic': conversation.topic,
      'timestamp': conversation.timestamp,

      Constants.REPLY_COUNT: conversation.replyCount,
      Constants.IS_READ: conversation.isRead,
            'isDeleted': conversation.isDeleted,

    };
    return json.encode(conversationMap);
  }).toList();

  await prefs.setStringList(
      SharedPrefsKeys.CONVERSATIONS, encodedConversations);

  // Update the isRead status of existing conversations
  List<Conversation> storedConversations = await getStoredConversations();
  for (var conversation in conversations) {
    int index = storedConversations.indexWhere(
      (c) => c.conversationId == conversation.conversationId,
    );
    if (index != -1) {
      storedConversations[index].isRead = conversation.isRead;
    }
  }

  // Store the updated conversations in shared preferences
  List<String> updatedEncodedConversations =
      storedConversations.map((conversation) {
    Map<String, dynamic> conversationMap = {
      Constants.CONVERSATION_ID: conversation.conversationId,
             'topic': conversation.topic,
      'timestamp': conversation.timestamp,
      Constants.REPLY_COUNT: conversation.replyCount,
      Constants.IS_READ: conversation.isRead,
            'isDeleted': conversation.isDeleted,

    };
    return json.encode(conversationMap);
  }).toList();

  await prefs.setStringList(
      SharedPrefsKeys.CONVERSATIONS, updatedEncodedConversations);
}
