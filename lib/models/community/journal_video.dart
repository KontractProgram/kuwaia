class JournalVideo {
  final int id;
  final String title;
  final String description;
  final String owner;
  final String youtubeLink;

  JournalVideo({required this.id, required this.title, required this.description, required this.owner, required this.youtubeLink});

  factory JournalVideo.fromMap(Map<String, dynamic> map) {
    return JournalVideo(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      owner: map['owner'] as String,
      youtubeLink: map['youtube_link'] as String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'owner': owner,
      'youtube_link': youtubeLink,
    };
  }
}