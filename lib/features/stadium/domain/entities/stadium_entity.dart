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
  final double pricePerHour;
  final String? instapayNumber;
  final String? instapayQr;
  final String? vodafoneCashNumber;

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
    this.pricePerHour = 0.0,
    this.instapayNumber,
    this.instapayQr,
    this.vodafoneCashNumber,
  });
}
