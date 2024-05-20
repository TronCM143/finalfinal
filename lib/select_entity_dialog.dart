import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectEntityDialog extends StatelessWidget {
  final List<DocumentSnapshot> users;
  final Function(DocumentSnapshot) onEntitySelected;

  const SelectEntityDialog({
    Key? key,
    required this.users,
    required this.onEntitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Device'),
      content: SingleChildScrollView(
        child: ListBody(
          children: users.map((user) {
            String email =
                (user.data() as Map<String, dynamic>)['deviceInfo']['email'];
            return ListTile(
              title: Text(email),
              onTap: () {
                Navigator.of(context).pop();
                onEntitySelected(user);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
