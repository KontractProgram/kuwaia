class Prompt {
  final int id;
  final String description;
  final String prompt;
  final int toolId;
  final String ownerId;
  bool? inJournal;

  Prompt({
    required this.id,
    required this.description,
    required this.prompt,
    required this.toolId,
    required this.ownerId,
    this.inJournal
  });

  factory Prompt.fromMap(Map<String, dynamic> map) {
    return Prompt(
      id: map['id'] as int,
      description: map['description'] as String,
      prompt: map['prompt'] as String,
      toolId: map['tool_id'] as int,
      ownerId: map['owner_id'] as String,
      inJournal: map['in_journal'] as bool? ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'prompt': prompt,
      'tool_id': toolId,
      'owner_id': ownerId,
      'in_journal': inJournal ?? false
    };
  }
}