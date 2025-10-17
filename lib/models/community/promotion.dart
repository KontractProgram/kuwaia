class Promotion {
  final int id;
  final String imageUrl;
  final int freelancerId;

  Promotion({required this.id, required this.imageUrl, required this.freelancerId});

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'] as int,
      imageUrl: map['image_url'] as String,
      freelancerId: map['freelancer_id'] as int
    );
  }
}