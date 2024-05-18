import 'package:location/location.dart';

class LocationService {
  static final Location _locationController = Location();

  static Future<void> getLocationUpdates(
      Function(LocationData) onLocationChanged) async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        // Handle the case where the user denies access to location services
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // Handle the case where the user denies location permission
        return;
      }
    }

    try {
      _locationController.onLocationChanged.listen(onLocationChanged);
    } catch (e) {
      // Handle any errors that occur while listening for location updates
      print('Error getting location updates: $e');
    }
  }
}
