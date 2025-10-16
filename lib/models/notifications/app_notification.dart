abstract class AppNotification {
  final int id;
  final String message;
  final DateTime createdAt;
  bool? read;

  AppNotification({
    required this.id,
    required this.message,
    required this.createdAt,
    this.read,
  });
}
