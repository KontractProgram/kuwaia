import 'package:kuwaia/models/notifications/app_notification.dart';

class PromptNotification extends AppNotification{
  final String senderId;
  final String receiverId;
  final int promptId;
  bool? accepted;

  PromptNotification({
    required super.id,
    required super.message,
    required this.senderId,
    required this.receiverId,
    required this.promptId,
    required super.createdAt,
    super.read,
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
      read: map['read'] as bool,
      accepted: map['accepted'] as bool?
    );
  }


}