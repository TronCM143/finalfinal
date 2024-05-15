import 'dart:async';
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
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  static const LatLng _pGooglePlex = LatLng(6.485651218461966, 124.85593053388185);
  LatLng? _currentP;
  List<String> _uids = [];
  String? _selectedUid;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showEntityListDialog();
            },
            child: Text('Select Entity'),
          ),
          Expanded(
            child: _currentP == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
                    initialCameraPosition: CameraPosition(
                      target: _pGooglePlex,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("_currentLocation"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                        position: _currentP!,
                      ),
                      if (_selectedUid != null)
                        Marker(
                          markerId: MarkerId(_selectedUid!),
                          icon: BitmapDescriptor.defaultMarker,
                          position: _currentP!,
                        ),
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 10,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
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
      _locationController.onLocationChanged.listen((LocationData currentLocation) {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          setState(() {
            _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _cameraToPosition(_currentP!);
          });
        }
      });
    } catch (e) {
      // Handle any errors that occur while listening for location updates
      print('Error getting location updates: $e');
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
              children: _uids.map((uid) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUid = uid;
                    });
                    Navigator.pop(context);
                    _fetchLocationFromFirestore(uid);
                  },
                  child: Text(uid),
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
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        var locationData = (docSnapshot.data() as Map<String, dynamic>)['location'];
        if (locationData != null) {
          double latitude = locationData['latitude'];
          double longitude = locationData['longitude'];
          setState(() {
            _currentP = LatLng(latitude, longitude);
            _cameraToPosition(_currentP!);
          });
        }
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching location from Firestore: $e');
    }
  }
}
