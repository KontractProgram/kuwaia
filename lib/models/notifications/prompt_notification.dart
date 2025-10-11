class PromptNotification {
  final int id;
  final String message;
  final String senderId;
  final String receiverId;
  final int promptId;
  final DateTime createdAt;
  bool? read;
  bool? accepted;

  PromptNotification({
    required this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.promptId,
    required this.createdAt,
    this.read,
    this.accepted
  });

  factory PromptNotification.fromMap(Map<String, dynamic> map) {
    return PromptNotification(
      id: map['id'] as int,
      message: map['message'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      createdAt: DateTime.parse(map['created_at']),
      promptId: map['prompt_id'] as int,
      read: map['read'] as bool?,
      accepted: map['accepted'] as bool?
    );
  }


}