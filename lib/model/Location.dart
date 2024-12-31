class Location {
  final String address;
  final double latitude;
  final double longitude;

  Location(
      {required this.address, required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  @override
  String toString() {
    return 'Location(address: $address, latitude: $latitude, longitude: $longitude)';
  }
}
