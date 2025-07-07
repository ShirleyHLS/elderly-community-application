// Location Model
class LocationModel {
  String address;
  double latitude;
  double longitude;

  LocationModel({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  static LocationModel empty() => LocationModel(
        address: '',
        latitude: 0.0,
        longitude: 0.0,
      );

  factory LocationModel.fromMap(Map<String, dynamic> data) {
    return LocationModel(
      address: data['address'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
