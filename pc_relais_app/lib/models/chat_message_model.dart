import 'package:uuid/uuid.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;

  ChatMessageModel({
    String? id,
    required this.senderId,
    required this.content,
    DateTime? timestamp,
    this.isRead = false,
    this.attachmentUrl,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.timestamp = timestamp ?? DateTime.now();

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? attachmentUrl,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
