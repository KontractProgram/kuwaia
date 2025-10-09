class Freelancer{
  final int id;
  final String name;
  final String skill;
  final String imageUrl;
  final double rating;
  final String email;
  final String aboutMe;

  Freelancer({required this.id, required this.name, required this.skill, required this.imageUrl, required this.rating, required this.email, required this.aboutMe});


  factory Freelancer.fromMap(Map<String, dynamic> map) {
    return Freelancer(
      id: map['id'] as int,
      name: map['name'] as String,
      skill: map['skill'] as String,
      imageUrl: map['imageUrl'] as String,
      rating: map['rating'] as double,
      email: map['email'] as String,
      aboutMe: map['about_me'] as String,
    );
  }
}