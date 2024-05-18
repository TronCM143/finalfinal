import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late Future<List<String>> _userEmailsFuture;

  @override
  void initState() {
    super.initState();
    print("Initializing DevicesPage...");
    _userEmailsFuture = _getUserEmails();
  }

  Future<List<String>> _getUserEmails() async {
    List<String> emails = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<String> uids = snapshot.docs.map((doc) => doc.id).toList();
      print("User IDs: $uids");
      for (String uid in uids) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        print("User Doc for UID $uid: ${userDoc.data()}");
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('email')) {
          emails.add(userData['email']);
        }
      }
    } catch (e) {
      print('Error fetching user emails: $e');
    }
    return emails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices'),
      ),
      body: FutureBuilder<List<String>>(
        future: _userEmailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final List<String> userEmails = snapshot.data ?? [];
            return ListView.builder(
              itemCount: userEmails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(userEmails[index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
