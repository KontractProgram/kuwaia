class Prompt {
  final int id;
  final String description;
  final String prompt;
  final int toolId;

  Prompt({
    required this.id,
    required this.description,
    required this.prompt,
    required this.toolId
  });

  factory Prompt.fromMap(Map<String, dynamic> map) {
    return Prompt(
        id: map['id'] as int,
        description: map['description'] as String,
        prompt: map['prompt'] as String,
        toolId: map['tool_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'prompt': prompt,
      'toolId': toolId,
    };
  }
}