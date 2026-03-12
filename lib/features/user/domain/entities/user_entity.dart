class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<String> friends;
  final double rating;
  final int totalRatings;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.friends = const [],
    this.rating = 0.0,
    this.totalRatings = 0,
  });
}
