class UpdateModel {
  final int id;
  final String name;
  final String contentUrl;
  final bool isYoutubeLink;
  final DateTime createdAt;
  String? redirectUrl;

  UpdateModel({
    required this.id,
    required this.name,
    required this.contentUrl,
    required this.isYoutubeLink,
    required this.createdAt,
    this.redirectUrl
  });

  factory UpdateModel.fromJson(Map<String, dynamic> map) {
    return UpdateModel(
      id: map['id'] as int,
      name: map['name'] ?? '',
      contentUrl: map['content_url'] ?? '',
      isYoutubeLink: map['is_youtube_link'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      redirectUrl: map['redirect_url'] ?? ''
    );
  }
}
