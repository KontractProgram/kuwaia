class ToolNotification{
  final int id;
  final String message;
  final String senderId;
  final String receiverId;
  final int toolId;
  final DateTime createdAt;
  bool? read;
  bool? accepted;

  ToolNotification({
    required this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.toolId,
    required this.createdAt,
    this.read,
    this.accepted
});

  factory ToolNotification.fromMap(Map<String, dynamic> map) {
    return ToolNotification(
        id: map['id'] as int,
        message: map['message'] as String,
        senderId: map['sender_id'] as String,
        receiverId: map['receiver_id'] as String,
        createdAt: DateTime.parse(map['created_at']),
        toolId: map['tool_id'] as int,
        read: map['read'] as bool?,
        accepted: map['accepted'] as bool?
    );
  }
}