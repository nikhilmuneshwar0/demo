import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '../services/places.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place initialPlace;
  final String apiKey;

  const PlaceDetailScreen({
    super.key,
    required this.initialPlace,
    required this.apiKey,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late Future<Place> _placeDetailsFuture;
  final PlacesService _placesService = PlacesService();
  Place _currentPlace = Place(id: '', name: ''); // Initialize with empty place
  bool _apiFailed = false;

  @override
  void initState() {
    super.initState();
    _currentPlace = widget.initialPlace;
    _placeDetailsFuture = _fetchPlaceDetails();
  }

  Future<Place> _fetchPlaceDetails() async {
    try {
      print('Fetching details for place: ${widget.initialPlace.id}');
      final detailedPlace = await _placesService.getPlaceDetails(widget.initialPlace.id);
      print('Received place details: ${detailedPlace.reviews?.length ?? 0} reviews');
      
      setState(() {
        _currentPlace = detailedPlace;
        _apiFailed = false;
      });
      return detailedPlace;
    } catch (e) {
      print('Error fetching place details: $e');
      setState(() {
        _apiFailed = true;
      });
      return widget.initialPlace;
    }
  }

  // In place_detail_screen.dart
List<Review> _getTestReviews() {
  return [
    Review(
      authorName: 'Test User 1',
      rating: 4.5,
      text: 'This is a test review to help with development. The food was great!',
      profilePhotoUrl: null, // Remove external dependency
      time: DateTime.now(),
    ),
    Review(
      authorName: 'Test User 2',
      rating: 3.0,
      text: 'Another test review. Service could be better but overall good experience.',
      profilePhotoUrl: null, // Remove external dependency
      time: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}

// (Removed misplaced snippet; logic is handled in _buildReviewCard)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPlace.name),
      ),
      body: FutureBuilder<Place>(
        future: _placeDetailsFuture,
        builder: (context, snapshot) {
          final place = snapshot.data ?? widget.initialPlace;
          final reviews = _apiFailed 
              ? _getTestReviews() 
              : (place.reviews ?? _getTestReviews());

          return SingleChildScrollView(
            child: Column(
              children: [
                if (place.photoReference != null)
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: 'https://maps.googleapis.com/maps/api/place/photo'
                          '?maxwidth=800'
                          '&photoreference=${place.photoReference}'
                          '&key=${widget.apiKey}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (place.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (place.vicinity != null)
                        Text(
                          'Address: ${place.vicinity!}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 24),
                      if (place.latitude != null && place.longitude != null)
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(place.latitude!, place.longitude!),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(place.id),
                                position: LatLng(place.latitude!, place.longitude!),
                              ),
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      _buildReviewsSection(reviews, _apiFailed),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsSection(List<Review> reviews, bool isTestData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Reviews ${isTestData ? '(Test Data)' : ''}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No reviews available',
              style: TextStyle(fontSize: 16),
            ),
          )
        else
          ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (review.profilePhotoUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(review.profilePhotoUrl!),
                    radius: 16,
                  )
                else
                  CircleAvatar(
                    radius: 16,
                    child: Text(review.authorName[0]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.text),
            if (review.time != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${review.time!.day}/${review.time!.month}/${review.time!.year}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}