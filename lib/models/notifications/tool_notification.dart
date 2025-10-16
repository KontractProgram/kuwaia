import 'package:kuwaia/models/notifications/app_notification.dart';

class ToolNotification extends AppNotification{
  final String senderId;
  final String receiverId;
  final int toolId;
  bool? accepted;

  ToolNotification({
    required super.id,
    required super.message,
    required this.senderId,
    required this.receiverId,
    required this.toolId,
    required super.createdAt,
    super.read,
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
        read: map['read'] as bool,
        accepted: map['accepted'] as bool?
    );
  }
}