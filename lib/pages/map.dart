import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import '../select_entity_dialog.dart';
import '../services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng? _currentP;
  List<DocumentSnapshot> _users = [];
  LatLng? _selectedLocation;
  String? _userUid;
  String? _userEmail;
  static const LatLng _pGooglePlex = LatLng(6.485651218461966, 124.85593053388185);

  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _fetchUsersFromFirestore();
    _getUserUid();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userUid = user?.uid;
      _userEmail = user?.email; // Set the initial email to the current user's email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: Column(
        children: [
          if (_userEmail != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('User Email: $_userEmail'),
            ),
          ElevatedButton(
            onPressed: () {
              _showEntityListDialog();
            },
            child: const Text('Select Device'),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> _fetchUsersFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _users = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _getLocationUpdates() async {
    LocationService.getLocationUpdates((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        _uploadLocationToFirestore(currentLocation.latitude!, currentLocation.longitude!);
      }
    });
  }

  Future<void> _uploadLocationToFirestore(double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_userUid).set({
        'location': GeoPoint(latitude, longitude),
      }, SetOptions(merge: true));
      print('Location uploaded to Firestore');
    } catch (e) {
      print('Error uploading location to Firestore: $e');
    }
  }

  Future<void> _showEntityListDialog() async {
    List<DocumentSnapshot> userEmailDocs = _users
        .where((user) =>
            user.data() != null &&
            (user.data() as Map<String, dynamic>)['deviceInfo'] != null &&
            (user.data() as Map<String, dynamic>)['deviceInfo']['email'] != null)
        .toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectEntityDialog(
          users: userEmailDocs,
          onEntitySelected: (emailDoc) {
            String email = (emailDoc.data() as Map<String, dynamic>)['deviceInfo']['email'];
            setState(() {
              _userEmail = email; // Update the displayed email
            });
            _fetchLocationFromFirestore(email);
          },
        );
      },
    );
  }

  Future<void> _fetchLocationFromFirestore(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('deviceInfo.email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        _locationSubscription?.cancel(); // Cancel any previous subscription
        _locationSubscription = userDoc.reference.snapshots().listen((snapshot) {
          if (snapshot.exists) {
            var locationData = snapshot['location'] as GeoPoint?;
            if (locationData != null) {
              double latitude = locationData.latitude;
              double longitude = locationData.longitude;
              LatLng newLocation = LatLng(latitude, longitude);
              print('New location fetched: $newLocation'); // Debugging print statement
              setState(() {
                _selectedLocation = newLocation;
              });
              _cameraToPosition(newLocation);
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching location from Firestore: $e');
    }
  }
}
