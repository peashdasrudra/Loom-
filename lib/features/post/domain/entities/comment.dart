import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  // convert comment into json

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'userName': userName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // convert json -> post
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userName: json['name'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] != null ? (json['timestamp'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}
