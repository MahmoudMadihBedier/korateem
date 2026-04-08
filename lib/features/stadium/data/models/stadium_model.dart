import '../../domain/entities/stadium_entity.dart';

class StadiumModel extends StadiumEntity {
  StadiumModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    super.photos,
    super.busyTimes,
    super.freeTimes,
    super.rating,
    super.address,
    super.phone,
    super.pricePerHour,
  });

  factory StadiumModel.fromFirestore(Map<String, dynamic> json, String id) {
    return StadiumModel(
      id: id,
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      busyTimes: (json['busyTimes'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      freeTimes: (json['freeTimes'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      address: json['address'] ?? json['location'],
      phone: json['phone'],
      pricePerHour: (json['pricePerHour'] ?? json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'photos': photos,
      'busyTimes': busyTimes,
      'freeTimes': freeTimes,
      'rating': rating,
      'address': address,
      'phone': phone,
      'pricePerHour': pricePerHour,
    };
  }
}
