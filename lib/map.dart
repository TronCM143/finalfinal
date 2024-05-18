import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'select_entity_dialog.dart';

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
  String? _userUid;
  static const LatLng _pGooglePlex =
      LatLng(6.485651218461966, 124.85593053388185);

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _fetchUsersFromFirestore();
    _getUserUid();
  }

  Future<void> _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userUid = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Column(
        children: [
          if (_userUid != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('User UID: $_userUid'),
            ),
          ElevatedButton(
            onPressed: () {
              _showEntityListDialog();
            },
            child: const Text('Select Device'),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  _mapController.complete(controller),
              initialCameraPosition: const CameraPosition(
                target: _pGooglePlex,
                zoom: 10,
              ),
              markers: _buildMarkers(),
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

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
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
      await FirebaseFirestore.instance.collection('users').doc(_userUid).set({
        'location': GeoPoint(latitude, longitude),
      }, SetOptions(merge: true));
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
        return SelectEntityDialog(
          users: _users,
          onEntitySelected: (uid) {
            _fetchLocationFromFirestore(uid);
          },
        );
      },
    );
  }

  Future<void> _fetchLocationFromFirestore(String uid) async {
    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        if (data['location'] != null) {
          var locationData = data['location'] as GeoPoint;
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
}
