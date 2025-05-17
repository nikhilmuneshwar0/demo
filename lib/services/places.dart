import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlacesService {
  static const String _apiKey = 'AIzaSyA0WCH9WfLWr-hQRLAlFdYxgW3wPICyqZs'; // Replace with your actual key
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const int _radius = 1500; // meters
  static const int _maxRetries = 2;

  Future<List<Place>> getNearbyPlaces(double lat, double lng, String type, int radius) async {
    if (type == 'all') {
      return _getAllPlaceTypes(lat, lng);
    }
    return _getPlacesWithRetry(lat, lng, type);
  }

  // Update your _getAllPlaceTypes method to use isolates for parallel processing
  Future<List<Place>> _getAllPlaceTypes(double lat, double lng) async {
    final placeTypes = [
      'restaurant',
      'bar',
      'cafe',
      'park',
      'bowling_alley',
      'night_club',
      'movie_theater'
    ];

    // Process in parallel but limit concurrency
    final results = await Future.wait(
      placeTypes.map((type) => _getPlacesWithRetry(lat, lng, type)),
      eagerError: true,
    );

    // Merge and deduplicate
    final allPlaces = results.expand((places) => places).toList();
    final uniquePlaces = allPlaces.toSet().toList();
    
    // Sort by rating
    uniquePlaces.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return uniquePlaces;
  }

  Future<List<Place>> _getPlacesWithRetry(double lat, double lng, String type, [int attempt = 0]) async {
    try {
      final url = '$_baseUrl?location=$lat,$lng&radius=$_radius&type=$type&key=$_apiKey';
      print('Places API Request: $url');

      final response = await http.get(Uri.parse(url));
      print('Places API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] != 'OK') {
          print('API Error: ${data['status']}');
          if (data['status'] == 'OVER_QUERY_LIMIT' && attempt < _maxRetries) {
            await Future.delayed(const Duration(seconds: 1));
            return _getPlacesWithRetry(lat, lng, type, attempt + 1);
          }
          throw Exception('API Error: ${data['status']}');
        }

        return (data['results'] as List).map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching places: $e');
      rethrow;
    }
  }

  


  // Helper method to build photo URL
  static String buildPhotoUrl(String? photoReference, {int maxWidth = 800, required String apiKey}) {
    if (photoReference == null) {
      return '';
    }
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$_apiKey';
  }

  void dispose() {}
}

// Equality and hashCode overrides should be placed inside the Place class in place.dart, not here.