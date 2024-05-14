import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  
  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            autofocus: true,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: widget.hintText,
                    ),
          ),
        );
  }
}