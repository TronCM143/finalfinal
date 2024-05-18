import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil {
  static Future<Map<String, dynamic>> getDeviceInformation(
      BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'Device Name': androidInfo.device,
          'Device Model': androidInfo.model,
          // Add more device information as needed
        };
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        // Add iOS device information retrieval here
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }
    return deviceData;
  }

  static Future<void> showDeviceInfoDialog(
      BuildContext context, Map<String, dynamic> deviceInfo) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: deviceInfo.length,
            itemBuilder: (context, index) {
              String key = deviceInfo.keys.elementAt(index);
              String value = deviceInfo[key].toString();
              return ListTile(
                title: Text(key),
                subtitle: Text(value),
              );
            },
          ),
        );
      },
    );
  }

  static Future<void> uploadDeviceInfoToFirestore(
      Map<String, dynamic> deviceInfo) async {
    try {
      // Get the current user's UID
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Upload device information to Firestore under the user's UID
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'deviceInfo': deviceInfo,
        }, SetOptions(merge: true));
        print('Device information uploaded to Firestore');
      }
    } catch (e) {
      // Handle errors here
      print('Error uploading device information to Firestore: $e');
    }
  }
}
