class LogDetails {
  final int id;
  final String logEmail;
  final String logPasswordHint;
  final int toolId;

  LogDetails({
    required this.id,
    required this.logEmail,
    required this.logPasswordHint,
    required this.toolId
  });

  factory LogDetails.fromMap(Map<String, dynamic> map) {
    return LogDetails(
      id: map['id'] as int,
      logEmail: map['log_email'] as String,
      logPasswordHint: map['log_password_hint'] as String,
      toolId: map['tool_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'log_email': logEmail,
      'log_password_hint': logPasswordHint,
      'tool_id': toolId,
    };
  }
}
