class Place {
  final String id;
  final String name;
  final double? rating;
  final String? photoReference;
  final String? vicinity;
  final double? latitude;
  final double? longitude;
  final List<String>? photos;
  final List<Review>? reviews;

  Place({
    required this.id,
    required this.name,
    this.rating,
    this.photoReference,
    this.vicinity,
    this.latitude,
    this.longitude,
    this.photos,
    this.reviews,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['place_id'],
      name: json['name'],
      rating: json['rating']?.toDouble(),
      photoReference: json['photos']?[0]['photo_reference'],
      vicinity: json['vicinity'],
      latitude: json['geometry']?['location']?['lat']?.toDouble(),
      longitude: json['geometry']?['location']?['lng']?.toDouble(),
      photos: (json['photos'] as List?)?.map((p) => p['photo_reference'] as String).toList(),
      // You'll need to parse reviews from the API response
    );
  }
}

class Review {
  final String authorName;
  final int rating;
  final String text;
  final String? profilePhotoUrl;

  Review({
    required this.authorName,
    required this.rating,
    required this.text,
    this.profilePhotoUrl,
  });
}