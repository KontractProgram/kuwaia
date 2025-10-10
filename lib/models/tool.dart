class Tool {
  final int id;
  final String name;
  final String visitLink;
  final String learningLink;
  final int groupId;
  String? imageUrl;

  Tool({required this.id, required this.name, required this.visitLink, required this.learningLink, required this.groupId, this.imageUrl});

  factory Tool.fromMap(Map<String, dynamic> map) {
    return Tool(
      id: map['id'] as int,
      name: map['name'] as String,
      visitLink: map['visit_link'] as String,
      learningLink: map['learning_link'] as String? ?? '',
      groupId: map['group_id'] as int,
      imageUrl: map['image_url'] as String? ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'visit_link': visitLink,
      'learning_link': learningLink,
      'group_id': groupId,
      'image_url': imageUrl
    };
  }
}