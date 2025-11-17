class ConversationInfo {
  final int mentoringId;
  final String contactName;
  final String contactPhoto;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final Map<String, dynamic> mentoring;

  ConversationInfo({
    required this.mentoringId,
    required this.contactName,
    required this.contactPhoto,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.mentoring,
  });
}


