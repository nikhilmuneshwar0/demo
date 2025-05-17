import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/location.dart';
import 'services/places.dart';
import 'widgets/places_view.dart';
import 'models/place.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NearbyPlacesApp());
}

class NearbyPlacesApp extends StatelessWidget {
  const NearbyPlacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Places',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const PlacesDiscoveryScreen(),
    );
  }
}

class PlacesDiscoveryScreen extends StatefulWidget {
  const PlacesDiscoveryScreen({super.key});

  @override
  State<PlacesDiscoveryScreen> createState() => _PlacesDiscoveryScreenState();
}

class _PlacesDiscoveryScreenState extends State<PlacesDiscoveryScreen> {
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();
  List<Place> _places = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String? _errorMessage;
  bool _usingDefaultLocation = false;
  int _selectedRadius = 1000; // Default 1km radius
  final List<int> _radiusOptions = [500, 1000, 2000, 5000]; // in meters
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    _fetchNearbyPlaces();
  }

  @override
  void dispose() {
    _placesService.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyPlaces() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _usingDefaultLocation = false;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      late double lat;
      late double lng;

      if (location != null && location.latitude != null && location.longitude != null) {
        lat = location.latitude!;
        lng = location.longitude!;
        _currentLat = lat;
        _currentLng = lng;
      } else {
        // Default to Times Square if location unavailable
        lat = 40.7580;
        lng = -73.9855;
        _usingDefaultLocation = true;
        _currentLat = lat;
        _currentLng = lng;
      }

      final places = await _placesService.getNearbyPlaces(
        lat, 
        lng, 
        _selectedCategory,
        _selectedRadius,
      );

      if (!mounted) return;
      
      setState(() {
        _places = places;
        _isLoading = false;
      });

      if (places.isEmpty) {
        setState(() {
          _errorMessage = 'No places found. Try another location or category.';
        });
      }

      if (_usingDefaultLocation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using default location. Check your GPS settings.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load places: ${e.toString().replaceAll('Exception: ', '')}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildRadiusSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<int>(
        value: _selectedRadius,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        underline: Container(),
        items: _radiusOptions.map((radius) {
          return DropdownMenuItem<int>(
            value: radius,
            child: Text(
              '${radius ~/ 1000} km',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null && value != _selectedRadius) {
            setState(() => _selectedRadius = value);
            _fetchNearbyPlaces();
          }
        },
        dropdownColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButton<String>(
      value: _selectedCategory,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      underline: Container(),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Places', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'restaurant', child: Text('Restaurants', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'bar', child: Text('Bars', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'cafe', child: Text('Cafés', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'park', child: Text('Parks', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'bowling_alley', child: Text('Bowling', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'night_club', child: Text('Clubs', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'movie_theater', child: Text('Cinemas', style: TextStyle(color: Colors.white))),
      ],
      onChanged: (value) {
        if (value != null && value != _selectedCategory) {
          setState(() => _selectedCategory = value);
          _fetchNearbyPlaces();
        }
      },
      dropdownColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding nearby places...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNearbyPlaces,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_places.isEmpty) {
      return const Center(
        child: Text(
          'No places found. Try another category or location.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return PlacesScrollView(
      places: _places,
      radius: _selectedRadius,
      apiKey: 'AIzaSyA0WCH9WfLWr-hQRLAlFdYxgW3wPICyqZs', // Replace with your actual API key
      onRefresh: _fetchNearbyPlaces,
      currentLat: _currentLat,
      currentLng: _currentLng,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Nearby'),
        actions: [
          _buildRadiusSelector(),
          _buildCategoryDropdown(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNearbyPlaces,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _usingDefaultLocation
          ? FloatingActionButton(
              onPressed: _fetchNearbyPlaces,
              tooltip: 'Retry with current location',
              child: const Icon(Icons.gps_fixed),
            )
          : null,
    );
  }
}