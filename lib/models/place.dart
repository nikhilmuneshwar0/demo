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

  // In place.dart
  factory Place.fromJson(Map<String, dynamic> json) {
    try {
      return Place(
        id: json['place_id'] ?? '',
        name: json['name'] ?? 'Unknown Place',
        rating: json['rating']?.toDouble(),
        photoReference: (json['photos'] as List?)?.firstOrNull?['photo_reference'],
        vicinity: json['vicinity'] ?? json['formatted_address'],
        latitude: json['geometry']?['location']?['lat']?.toDouble(),
        longitude: json['geometry']?['location']?['lng']?.toDouble(),
        photos: (json['photos'] as List?)?.map((p) => p['photo_reference'] as String).toList(),
        reviews: json['reviews'] != null 
            ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
            : null,
      );
    } catch (e) {
      print('Error parsing Place: $e');
      return Place(
        id: json['place_id'] ?? '',
        name: json['name'] ?? 'Unknown Place',
      );
    }
  }
}

class Review {
  final String authorName;
  final double rating;  // Changed from int to double
  final String text;
  final String? profilePhotoUrl;
  final DateTime? time;

  Review({
    required this.authorName,
    required this.rating,
    required this.text,
    this.profilePhotoUrl,
    this.time,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] ?? 'Anonymous',
      rating: (json['rating']?.toDouble() ?? 0.0),
      text: json['text'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      time: json['time'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['time'] * 1000)
          : null,
    );
  }
}