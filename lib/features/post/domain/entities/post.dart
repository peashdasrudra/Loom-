import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loom/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // ---------------------------
  // MINIMALLY FIXED fromJson()
  // ---------------------------
  factory Post.fromJson(Map<String, dynamic> json) {
    // safely parse comments
    final List<Comment> comments =
        (json['comments'] as List<dynamic>?)
            ?.map((c) {
              if (c is Comment) return c;
              if (c is Map<String, dynamic>) return Comment.fromJson(c);
              if (c is Map)
                return Comment.fromJson(Map<String, dynamic>.from(c));
              return null;
            })
            .whereType<Comment>()
            .toList() ??
        [];

    // safely parse likes
    final rawLikes = json['likes'];
    List<String> likesList = <String>[];
    if (rawLikes is List) {
      likesList = rawLikes
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // safely parse timestamp
    DateTime parsedTimestamp;
    final rawTs = json['timestamp'];
    if (rawTs is Timestamp) {
      parsedTimestamp = rawTs.toDate();
    } else if (rawTs is DateTime) {
      parsedTimestamp = rawTs;
    } else if (rawTs is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTs);
    } else if (rawTs is String) {
      parsedTimestamp = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return Post(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['name'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      timestamp: parsedTimestamp,
      likes: likesList,
      comments: comments,
    );
  }
}
