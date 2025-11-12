class ChatMessage {
  final int messageId;
  final String content;
  final int senderId;
  final String senderName;
  final DateTime timestamp;

  ChatMessage({
    required this.messageId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as int,
      content: json['content'] as String,
      senderId: json['senderId'] as int,
      senderName: json['senderName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool isMine(int currentUserId) => senderId == currentUserId;
}


