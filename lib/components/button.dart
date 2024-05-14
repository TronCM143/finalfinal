import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  
  final Function()? onTap;
  final String text;

  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
        margin: const EdgeInsets.symmetric(horizontal: 70,),
        decoration: BoxDecoration(
          color: const  Color(0xFF5BABCD),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}