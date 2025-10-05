class Short {
  final int id;
  final String title;
  final String videoUrl;
  final DateTime createdAt;

  Short({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.createdAt,
  });

  factory Short.fromJson(Map<String, dynamic> json) {
    return Short(
      id: json['id'] as int,
      title: json['title'] ?? '',
      videoUrl: json['video_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
