class Profile {
  final String id;
  final String email;
  final String username;
  final bool verified;
  final bool onboarded;

  Profile({
    required this.id,
    required this.email,
    required this.username,
    required this.verified,
    required this.onboarded
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      verified: map['verified'] as bool? ?? false,
      onboarded: map['onboarded'] as bool? ?? false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'verified': verified,
      'onboarded': onboarded
    };
  }
}
