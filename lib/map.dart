import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();
  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();
  static const LatLng _pGooglePlex =
  LatLng(6.499612618473192, 124.84422050314143);
  LatLng? _currentP;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? Center(
        child:
        CircularProgressIndicator(), // Display a loading indicator while waiting for location updates
      )
          : GoogleMap(
        onMapCreated: ((GoogleMapController controller) =>
            _mapController.complete(controller)),
        initialCameraPosition: CameraPosition(
          target: _pGooglePlex,
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: MarkerId("_currentLocation"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
            position: _currentP!,
          ),
          Marker(
            markerId: MarkerId("_sourceLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: _pGooglePlex,
          ),
        },
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 20,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
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
      _locationController.onLocationChanged
          .listen((LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            _currentP =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _cameraToPosition(_currentP!);
          });
        }
      });
    } catch (e) {
      // Handle any errors that occur while listening for location updates
      print('Error getting location updates: $e');
    }
  }
}