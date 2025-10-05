class Latest{
  final int id;
  final String title;
  final String description;
  final String visitLink;
  final DateTime releaseTime;
  List<String>? tags;
  String? imageUrl;
  int? toolId;

  Latest({
    required this.id,
    required this.title,
    required this.description,
    required this.visitLink,
    required this.releaseTime,
    this.tags,
    this.imageUrl,
    this.toolId
  });

  factory Latest.fromMap(Map<String, dynamic> map) {
    return Latest(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      visitLink: map['visit_link'] as String,
      releaseTime: DateTime.parse(map['release_time'] as String),
      tags: (map['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      imageUrl: map['image_url'] as String? ?? '',
      toolId: map['tool_id'] as int? ?? -1
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'visit_link': visitLink,
      'release_time': releaseTime,
      'tags': tags,
      'image_url': imageUrl,
      'tool_id': toolId
    };
  }
}