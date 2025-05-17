import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '/place_detail_screen.dart'; // Make sure to import your detail screen

class PlacesScrollView extends StatelessWidget {
  final List<Place> places;
  final String apiKey;
  final int radius;
  final Future<void> Function() onRefresh;
  final double? currentLat;
  final double? currentLng;
  
  const PlacesScrollView({
    super.key,
    required this.places,
    required this.apiKey,
    required this.radius,
    required this.onRefresh,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Within ${radius ~/ 1000} km',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return _buildPlaceCard(context, place);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceCard(BuildContext context, Place place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(
              place: place,
              apiKey: apiKey,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // Background image
          if (place.photoReference != null)
            CachedNetworkImage(
              imageUrl: 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${place.photoReference}&key=$apiKey',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Container(color: Colors.grey[800]),
            )
          else
            Container(color: Colors.grey[800]),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          
          // Place details
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
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
                        place.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${_getDistanceText(place)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (place.vicinity != null)
                  Text(
                    place.vicinity!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          
          // Action buttons
          Positioned(
            right: 20,
            bottom: 150,
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white, size: 32),
                  onPressed: () {
                    // Handle favorite action
                    _handleFavorite(context, place);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.directions, color: Colors.white, size: 32),
                  onPressed: () {
                    _openDirections(place);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 32),
                  onPressed: () {
                    _sharePlace(place);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleFavorite(BuildContext context, Place place) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${place.name} added to favorites')),
    );
    // Implement your favorite logic here
  }

  void _openDirections(Place place) {
    if (place.latitude == null || place.longitude == null) return;
    // Implement directions opening logic
    // Example: Launch Google Maps with the coordinates
  }

  void _sharePlace(Place place) {
    // Implement share functionality
    final text = 'Check out ${place.name} at ${place.vicinity}';
    // Use share plugin: https://pub.dev/packages/share
  }

  String _getDistanceText(Place place) {
    if (currentLat == null || currentLng == null || 
        place.latitude == null || place.longitude == null) {
      return 'Distance unknown';
    }
    
    final distance = _calculateDistance(
      currentLat!,
      currentLng!,
      place.latitude!,
      place.longitude!,
    );
    
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m away';
    } else {
      return '${distance.toStringAsFixed(1)} km away';
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - 
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * 
        (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}