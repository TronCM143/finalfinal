import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentP;
  List<DocumentSnapshot> _users = [];
  LatLng? _selectedLocation;
  static const LatLng _pGooglePlex =
      LatLng(6.485651218461966, 124.85593053388185);
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _fetchUsersFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) =>
                _mapController.complete(controller),
            initialCameraPosition: const CameraPosition(
              target: _pGooglePlex,
              zoom: 10,
            ),
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
          ),
          if (_distance != 0)
            Positioned(
              top: 16.0,
              right: 16.0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                child: Text(
                  'Distance: $_distance meters',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _showEntityListDialog();
              },
              child: Text('Select Entity'),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    if (_currentP != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("_currentLocation"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: _currentP!,
        ),
      );
    }

    if (_selectedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("_selectedLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: _selectedLocation!,
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    Set<Polyline> polylines = {};

    if (_currentP != null && _selectedLocation != null) {
      List<LatLng> polylineCoordinates = [
        _currentP!,
        _selectedLocation!,
      ];

      Polyline polyline = Polyline(
        polylineId: PolylineId('poly'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      );

      polylines.add(polyline);
    }

    return polylines;
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    if (!_mapController.isCompleted) {
      final GoogleMapController controller = await _mapController.future;
      CameraPosition _newCameraPosition = CameraPosition(
        target: pos,
        zoom: 13,
      );
      await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
    }
  }

  Future<void> _fetchUsersFromFirestore() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _users = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _getLocationUpdates() async {
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
          });
          _uploadLocationToFirestore(
              currentLocation.latitude!, currentLocation.longitude!);
          _calculateDistance();
        }
      });
    } catch (e) {
      // Handle any errors that occur while listening for location updates
      print('Error getting location updates: $e');
    }
  }

  Future<void> _uploadLocationToFirestore(
      double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('current_location')
          .set({
        'latitude': latitude,
        'longitude': longitude,
      });
      print('Location uploaded to Firestore');
    } catch (e) {
      // Handle errors here
      print('Error uploading location to Firestore: $e');
    }
  }

  Future<void> _showEntityListDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Entity'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _users.map((user) {
                return TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchLocationFromFirestore(user.id);
                  },
                  child: Text(user.id),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchLocationFromFirestore(String uid) async {
    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        var locationData = (docSnapshot.data()
            as Map<String, dynamic>)['location'] as GeoPoint;
        if (locationData != null) {
          double latitude = locationData.latitude;
          double longitude = locationData.longitude;
          LatLng newLocation = LatLng(latitude, longitude);
          setState(() {
            _selectedLocation =
                newLocation; // Set selectedLocation to the fetched location
          });
          _cameraToPosition(newLocation);
        }
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching location from Firestore: $e');
    }
  }

  // Calculate distance between two LatLng points
  void _calculateDistance() {
    if (_currentP != null && _selectedLocation != null) {
      double distanceInMeters = _calculateDistanceInMeters(
          _currentP!.latitude,
          _currentP!.longitude,
          _selectedLocation!.latitude,
          _selectedLocation!.longitude);

      setState(() {
        _distance = distanceInMeters;
      });
    }
  }

  // Function to calculate distance between two LatLng points
  double _calculateDistanceInMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
