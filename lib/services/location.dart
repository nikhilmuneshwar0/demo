import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  
  Future<LocationData?> getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return null;
    }
    
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return null;
    }
    
    return await _location.getLocation();
  }
}