class News{
  final int id;
  final String title;
  final String description;
  final String owner;
  final String content;
  final DateTime releaseTime;
  String? imageUrl;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.owner,
    required this.content,
    required this.releaseTime,
    this.imageUrl,
  });

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
        id: map['id'] as int,
        title: map['title'] as String,
        description: map['description'] as String,
        owner: map['owner'] as String,
        content: map['content'] as String,
        releaseTime: map['release_time'] as DateTime,
        imageUrl: map['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'owner': owner,
      'content': content,
      'release_time': releaseTime,
      'image_url': imageUrl,
    };
  }
}