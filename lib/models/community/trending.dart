class Trending{
  final int id;
  final int toolId;
  final int groupId;

  Trending({required this.id, required this.toolId, required this.groupId});

  factory Trending.fromMap(Map<String, dynamic> map) {
    return Trending(
      id: map['id'] as int,
      toolId: map['tool_id'] as int,
      groupId: map['group_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tool_id': toolId,
      'group_id': groupId
    };
  }
}