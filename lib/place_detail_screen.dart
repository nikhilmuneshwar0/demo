import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;
  final String apiKey;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.apiKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo Gallery
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: 3, // Replace with actual photo count
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: place.photoReference != null
                        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${place.photoReference}&key=$apiKey'
                        : 'https://via.placeholder.com/800x400',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            
            // Place Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  if (place.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(place.rating.toString()),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'About this place',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  if (place.vicinity != null)
                    Text(place.vicinity!),
                  const SizedBox(height: 16),
                  
                  // Mini Map
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            place.latitude ?? 0,
                            place.longitude ?? 0,
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(place.id),
                            position: LatLng(
                              place.latitude ?? 0,
                              place.longitude ?? 0,
                            ),
                          ),
                        },
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reviews Section
                  const Text(
                    'Reviews',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  _buildReviewList(), // You'll need to implement this
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement directions functionality
        },
        child: const Icon(Icons.directions),
      ),
    );
  }

  Widget _buildReviewList() {
    // Replace with actual reviews from your Place model
    return Column(
      children: [
        _buildReviewItem('John Doe', 4, 'Great place with amazing atmosphere!'),
        _buildReviewItem('Jane Smith', 5, 'Loved the food and service was excellent.'),
      ],
    );
  }

  Widget _buildReviewItem(String name, int rating, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating ? Colors.amber : Colors.grey,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}