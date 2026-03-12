class StadiumEntity {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final List<String> photos;
  final List<Map<String, dynamic>> busyTimes;
  final List<Map<String, dynamic>> freeTimes;
  final double rating;
  final String? address;
  final String? phone;

  StadiumEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.photos = const [],
    this.busyTimes = const [],
    this.freeTimes = const [],
    this.rating = 0.0,
    this.address,
    this.phone,
  });
}
