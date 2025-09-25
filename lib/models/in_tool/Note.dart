class Note {
  final int id;
  final String note;
  final int toolId;

  Note({
    required this.id,
    required this.note,
    required this.toolId
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      note: map['note'] as String,
      toolId: map['tool_id'] as int
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note': note,
      'tool_id': toolId
    };
  }
}