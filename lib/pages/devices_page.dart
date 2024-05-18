import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No devices found'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot device = snapshot.data!.docs[index];
              Map<String, dynamic>? deviceInfo =
                  device.data() as Map<String, dynamic>?; // Explicit cast
              if (deviceInfo == null) {
                return SizedBox.shrink();
              }
              return ListTile(
                title: Text(device.id), // UID of the device
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Device Name: ${deviceInfo['Device Name'] ?? 'null'}'),
                    Text(
                        'Device Model: ${deviceInfo['Device Model'] ?? 'null'}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
