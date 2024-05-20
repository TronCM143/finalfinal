import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OnlineStatus {
  online,
  offline,
}

class UserDeviceInfo {
  final String uid;
  final String email;
  final Map<String, dynamic>? deviceInfo;
  final String? name;
  final String? lastName;
  final String? age;
  final OnlineStatus onlineStatus;

  UserDeviceInfo({
    required this.uid,
    required this.email,
    required this.deviceInfo,
    this.name,
    this.lastName,
    this.age,
    required this.onlineStatus,
  });
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
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
            final users = snapshot.data!.docs;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: users.map((user) {
                  var userData = user.data() as Map<String, dynamic>;
                  var deviceInfo =
                      userData['deviceInfo'] as Map<String, dynamic>?;

                  OnlineStatus onlineStatus = (userData['online'] ?? false)
                      ? OnlineStatus.online
                      : OnlineStatus.offline;

                  UserDeviceInfo userDeviceInfo = UserDeviceInfo(
                    uid: user.id,
                    email: userData['email'] ?? 'No Email',
                    deviceInfo: deviceInfo,
                    name: userData['name'],
                    lastName: userData['lastName'],
                    age: userData['age'],
                    onlineStatus: onlineStatus,
                  );

                  String? profilePictureUrl = userData['profilePictureUrl'];

                  return Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: profilePictureUrl != null
                                  ? NetworkImage(profilePictureUrl)
                                  : AssetImage('assets/placeholder_image.jpg')
                                      as ImageProvider,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userDeviceInfo.email,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'UID: ${userDeviceInfo.uid}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        if (userDeviceInfo.deviceInfo != null) ...[
                          Text(
                            'Device Information:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          ...userDeviceInfo.deviceInfo!.entries.map((entry) {
                            if (entry.key != 'email') {
                              return Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                    '${entry.key}: ${entry.value ?? 'Unknown'}'),
                              );
                            } else {
                              return SizedBox
                                  .shrink(); // Hide email from device information
                            }
                          }),
                        ],
                        SizedBox(height: 10),
                        if (userDeviceInfo.name != null ||
                            userDeviceInfo.lastName != null ||
                            userDeviceInfo.age != null) ...[
                          Text(
                            'Personal Information:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (userDeviceInfo.name != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('Name: ${userDeviceInfo.name}'),
                            ),
                          if (userDeviceInfo.lastName != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child:
                                  Text('Last Name: ${userDeviceInfo.lastName}'),
                            ),
                          if (userDeviceInfo.age != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('Age: ${userDeviceInfo.age}'),
                            ),
                        ],
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              userDeviceInfo.onlineStatus == OnlineStatus.online
                                  ? Icons.circle
                                  : Icons.circle,
                              color: userDeviceInfo.onlineStatus ==
                                      OnlineStatus.online
                                  ? Colors.green
                                  : Colors.black,
                              size: 12,
                            ),
                            SizedBox(width: 5),
                            Text(
                              userDeviceInfo.onlineStatus == OnlineStatus.online
                                  ? 'Online'
                                  : 'Offline',
                              style: TextStyle(
                                color: userDeviceInfo.onlineStatus ==
                                        OnlineStatus.online
                                    ? Colors.green
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showEditDialog(context, userDeviceInfo);
                          },
                          child: Text('Edit'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserDeviceInfo userDeviceInfo) {
    final _formKey = GlobalKey<FormState>();
    String? name = userDeviceInfo.name;
    String? lastName = userDeviceInfo.lastName;
    String? age = userDeviceInfo.age;

    var emailController = TextEditingController(text: userDeviceInfo.email);
    var nameController = TextEditingController(text: name);
    var lastNameController = TextEditingController(text: lastName);

    var ageController = TextEditingController(text: age);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User Info'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                  ),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          int.tryParse(value) == null) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userDeviceInfo.uid)
                      .update({
                        'name': nameController.text,
                        'lastName': lastNameController.text,
                        'age': ageController.text,
                      })
                      .then((_) => Navigator.of(context).pop())
                      .catchError(
                          (error) => print('Failed to update user: $error'));
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
