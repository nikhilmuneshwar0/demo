// ignore_for_file: avoid_print, unused_field

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlacesService {
  static const String _apiKey = 'AIzaSyA0WCH9WfLWr-hQRLAlFdYxgW3wPICyqZs'; // Replace with your actual key
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String _detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
  static const int _defaultRadius = 1500; // meters
  static const int _maxRetries = 2;

  Future<List<Place>> getNearbyPlaces(double lat, double lng, String type, int radius) async {
    if (type == 'all') {
      return _getAllPlaceTypes(lat, lng, radius);
    }
    return _getPlacesWithRetry(lat, lng, type, radius);
  }

 Future<Place> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_detailsUrl?place_id=$placeId&'
            'fields=name,rating,formatted_address,photos,reviews,geometry&'
            'key=$_apiKey')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'] ?? {};
          return Place.fromJson(result);
        }
        throw Exception('API Error: ${data['status']}');
      }
      throw Exception('Failed to load place details: ${response.statusCode}');
    } catch (e) {
      print('Error in getPlaceDetails: $e');
      rethrow;
    }
  }

  Future<List<Place>> _getAllPlaceTypes(double lat, double lng, int radius) async {
    const placeTypes = [
      'restaurant',
      'bar',
      'cafe',
      'park',
      'bowling_alley',
      'night_club',
      'movie_theater'
    ];

    try {
      final results = await Future.wait(
        placeTypes.map((type) => _getPlacesWithRetry(lat, lng, type, radius)),
        eagerError: true,
      );

      final allPlaces = results.expand((places) => places).toList();
      final uniquePlaces = allPlaces.toSet().toList();
      
      uniquePlaces.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      return uniquePlaces;
    } catch (e) {
      print('Error fetching all place types: $e');
      rethrow;
    }
  }

  Future<List<Place>> _getPlacesWithRetry(
    double lat, 
    double lng, 
    String type, 
    int radius, 
    [int attempt = 0]
  ) async {
    try {
      final url = '$_baseUrl?location=$lat,$lng&radius=$radius&type=$type&'
          'fields=name,rating,vicinity,photos,geometry,place_id&'
          'key=$_apiKey';
      
      print('Places API Request: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] != 'OK') {
          if (data['status'] == 'OVER_QUERY_LIMIT' && attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: 1 << attempt));
            return _getPlacesWithRetry(lat, lng, type, radius, attempt + 1);
          }
          throw Exception('API Error: ${data['status']}');
        }

        return (data['results'] as List).map((json) => Place.fromJson(json)).toList();
      }
      throw Exception('HTTP Error ${response.statusCode}');
    } catch (e) {
      print('Error in _getPlacesWithRetry: $e');
      rethrow;
    }
  }

  static String buildPhotoUrl(String? photoReference, {int maxWidth = 800}) {
    if (photoReference == null || photoReference.isEmpty) {
      return '';
    }
    return 'https://maps.googleapis.com/maps/api/place/photo?'
        'maxwidth=$maxWidth&photoreference=$photoReference&key=$_apiKey';
  }

  void dispose() {
    // Dispose any resources if needed
  }
}