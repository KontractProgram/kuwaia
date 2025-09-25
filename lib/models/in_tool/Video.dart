class Video {
  final int id;
  final String videoLink;
  final int toolId;

  Video({
    required this.id,
    required this.videoLink,
    required this.toolId
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
        id: map['id'] as int,
        videoLink: map['video_link'] as String,
        toolId: map['tool_id'] as int
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video_link': videoLink,
      'tool_id': toolId
    };
  }
}