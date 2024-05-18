import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectEntityDialog extends StatelessWidget {
  final List<DocumentSnapshot> users;
  final Function(String) onEntitySelected;

  const SelectEntityDialog({
    Key? key,
    required this.users,
    required this.onEntitySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Entity'),
      content: SingleChildScrollView(
        child: ListBody(
          children: users.map((user) {
            return TextButton(
              onPressed: () {
                Navigator.pop(context);
                onEntitySelected(user.id);
              },
              child: Text(user.id),
            );
          }).toList(),
        ),
      ),
    );
  }
}
